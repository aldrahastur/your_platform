class GroupsController < ApplicationController
  before_action :load_resource, only: [:show, :update, :destroy]
  authorize_resource :group, except: [:create, :test_welcome_message]
  respond_to :html, :json, :csv, :ics

  def index
    @group = @parent_group = Group.find(params[:group_id]) if params[:group_id]
    @groups = (@parent_group.try(:child_groups) || Group.all).includes(:flags)

    # TODO: Authorize

    set_current_navable(@parent_group || Page.intranet_root)
    set_current_title(@parent_group.try(:title) || t(:groups))
    set_current_activity :is_looking_at_group, @parent_group if @parent_group
  end

  def index_mine
    set_current_navable current_user
    @groups = current_user.groups
    respond_with @groups
  end

  def show
    if @group
      if request.format.html?
        redirect_to_group_tab
        return

      elsif request.format.xls? || request.format.csv? || request.format.json?
        Rack::MiniProfiler.step('groups#show controller: fetch memberships') do
          # If this is a collection group, e.g. the corporations_parent group,
          # do not list the single members.
          #
          if @group.group_of_groups?
            @memberships = []
            @child_groups = @group.child_groups - [@group.find_officers_parent_group]

          # This is a regular group.
          #
          else
            @memberships = @group.memberships_for_member_list
          end
        end

        # The user might provide a `valid_from` option as constraint on the validity range.
        #
        if params[:valid_from].present?
          @memberships = @memberships.started_after(params[:valid_from].to_datetime)
        end

        Rack::MiniProfiler.step('groups#show controller: cancan') do
          # Make sure only members that are allowed to be seen are in this array!
          #
          allowed_member_ids = @group.members.accessible_by(current_ability).pluck(:id)
          allowed_memberships = @group.memberships.where(descendant_id: allowed_member_ids)
          @memberships = @memberships & allowed_memberships
        end

        Rack::MiniProfiler.step('groups#show controller: fetch members') do
          # Fill also the members into a separate variable.
          #
          @members = @group.members.includes(:links_as_child).where(dag_links: {id: @memberships.map(&:id)})

          # For some special groups, the first method of retreiving the members does not work.
          # Fallback to these slower methods:
          @members = User.includes(:links_as_child).where(dag_links: {id: @memberships.map(&:id)}) if @members.empty?
          @members = @memberships.collect { |membership| membership.user } if @members.empty?
        end

        # for performance reasons deactivated for the moment.
        # fill_map_address_fields
        @large_map_address_fields = []

        # @posts = @group.posts.order("sent_at DESC").limit(10)

        @new_user_group_membership = @group.build_membership
      end
    end

    if request.format.csv? || request.format.xls?
      list_preset = params[:list]
      list_preset_i18n = I18n.translate(list_preset) if list_preset.present?
      @file_title = "#{@group.name} #{list_preset_i18n} #{Time.zone.now}".parameterize
      @list_export = list_export_by_preset(list_preset)
    end

    # Log exports.
    #
    if not request.format.html?
      PublicActivity::Activity.create!(
        trackable: @group,
        key: "Export #{params[:list] || params[:pdf_type]}",
        owner: current_user,
        parameters: params.except('authenticity_token')
      )
    end


    respond_to do |format|
      format.json do
        authorize! :read, @group
        render json: @group.serializable_hash.merge({member_count: @memberships.count})
      end
      format.csv do
        authorize! :read, @group
        authorize! :export_member_list, @group

        # The export for "DPAG Internetmarke" requires an "latin western 1" encoding.
        # Everything else, we encode as UTF-8.
        #
        csv_data = @list_export.to_csv
        if list_preset.try(:include?, 'dpag_internetmarke')
          csv_data = csv_data.encode('ISO-8859-1')
        else
          # See: http://railscasts.com/episodes/362-exporting-csv-and-excel
          #bom = "\377\376".force_encoding('utf-16le')
          bom = "\xEF\xBB\xBF".force_encoding('utf-8') # UTF-8
          csv_data = bom + csv_data
        end

        send_data csv_data, filename: "#{@file_title}.csv"
      end
      format.xls do
        authorize! :read, @group
        authorize! :export_member_list, @group

        send_data(@list_export.to_xls, type: 'application/xls; charset=utf-8; header=present', filename: "#{@file_title}.xls")
      end
      format.pdf do
        authorize! :read, @group
        authorize! :export_member_list, @group

        if params[:sender].present?
          # TODO: This should not be inside a GET request; but I wasn't sure how to do it properly.
          session[:address_labels_pdf_sender] = params[:sender]
        end
        options = {sender: params[:sender], book_rate: params[:book_rate], export_user: current_user}

        if params[:pdf_type].present?
          options[:type] = "AddressLabelsDpag7037Pdf" if params[:pdf_type].include?("dpag")
          options[:type] = "AddressLabelsZweckform3475Pdf" if params[:pdf_type].include?("zweckform")
        else
          options[:type] = "AddressLabelsZweckform3475Pdf"
        end

        file_title = "#{I18n.t(:address_labels)} #{@group.name} #{Time.zone.now}".parameterize

        # Possible dispositions: attachment, inline.
        # Windows users with the Adobe Reader browser plugin can't print with 100% scale from the browser plugin.
        # They would need to download and open the file in Adobe Reader standalone to print at 100% scale.
        # Therefore, we use 'attachment' here in order to prevent the use of the browser plugin.
        #
        send_data(@group.members_to_pdf(options), filename: "#{file_title}.pdf", type: 'application/pdf', disposition: 'inline')
      end
    end

    metric_logger.log_event @group.try(:attributes), type: :show_group
  end

  def update
    @group.update_attributes(group_params)
    respond_to do |format|
      format.json { respond_with_bip @group.reload }
    end
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_groups
    else
      @parent = Group
    end

    authorize! :create_group_for, @parent
    @new_group = @parent.create(name: I18n.t(:new_group))

    respond_with @new_group
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # POST groups/123/test_welcome_message
  def test_welcome_message
    @group = Group.find params[:group_id]
    authorize! :update, @group
    notification = @group.send_welcome_message_to current_user
    Notification.deliver_for_user current_user
    respond_to do |format|
      format.json { render json: notification }
    end
  end

  private

  def list_export_by_preset(list_preset)
    case list_preset
    when 'name_list', '', nil
      ListExports::NameList.from_group(@group)
    when 'address_list'
      ListExports::AddressList.from_group(@group)
    when 'member_development', 'join_statistics'
      ListExport.new(@group, list_preset)
    when 'dpag_internetmarken'
      ListExports::DpagInternetmarken.from_group(@group)
    when 'dpag_internetmarken_in_germany'
      ListExports::DpagInternetmarkenInGermany.from_group(@group)
    when 'dpag_internetmarken_not_in_germany'
      ListExports::DpagInternetmarkenNotInGermany.from_group(@group)
    when 'birthday_list'
      ListExports::BirthdayList.from_group(@group, quater: params[:quater])
    when 'special_birthdays'
      ListExports::SpecialBirthdays.from_group(@group, quater: params[:quater])
    when 'deceased_members'
      ListExports::DeceasedMembers.from_group(@group)
    when 'former_and_deceased_members'
      ListExports::FormerAndDeceasedMembers.from_group(@group)
    else
      ListExport.new(@members, list_preset)
    end
  end

  def load_resource
    @group = Group.find params[:id]
    point_navigation_to @group
  end

  # This method returns the request parameters and their values as long as the user
  # is permitted to change them.
  #
  # This mechanism protects from mass assignment hacking and replaces the old
  # attr_accessible mechanism.
  #
  # For more information, have a look at these resources:
  #   https://github.com/rails/strong_parameters/
  #   http://railscasts.com/episodes/371-strong-parameters
  #
  def group_params
    # STI override:
    params[:group] ||= params[:corporation] # for Corporation objects
    params[:group] ||= params[:officer_group] # for OfficerGroup objects

    permitted_keys = []
    permitted_keys += [:name, :extensive_name] if can? :rename, @group
    permitted_keys += [:token] if can? :change_token, @group
    permitted_keys += [:internal_token] if can? :change_internal_token, @group
    permitted_keys += [:direct_members_titles_string] if can? :update_memberships, @group
    permitted_keys += [:body, :welcome_message] if can? :update, @group
    permitted_keys += [:mailing_list_sender_filter] if can? :update, @group
    params.require(:group).permit(*permitted_keys)
  end

  def fill_map_address_fields
    fill_small_map_address_fields
    fill_large_map_address_fields
  end

  def fill_small_map_address_fields
    # On collection groups, e.g. the corporations_parent group, only the
    # groups should be shown on the map. These groups have a lot of
    # child groups with address profile fields.
    #
    if child_groups_map_profile_fields.count > 0
      @users_map_profile_fields = []
      @groups_map_profile_fields = child_groups_map_profile_fields
    elsif child_groups_map_profile_fields.count == 0

      # To prevent long loading times, users map profile fields should only
      # be loaded when there are not too many.
      #
      # TODO: Remove this when the map addresses are cached.
      # TODO: Cache map address fields.
      #
      if @group.member_ids.count < 100  # arbitrary limit.
        @users_map_profile_fields = users_map_profile_fields
      else
        @users_map_profile_fields = []
      end

      # Only if there are descendant group address fields, fill the variable
      # for the large map. If there is only the own address, the view
      # will render a small map instead of the large one.
      #
      if descendant_groups_map_profile_fields.count > 0
        @groups_map_profile_fields = own_map_profile_fields + descendant_groups_map_profile_fields
      else
        @groups_map_profile_fields = []
      end
    end
  end

  def fill_large_map_address_fields
    # TODO: Make this more efficient.
    # This can be done by using @user_map_profile_fields and @group_map_profile_fields
    # separately when creating the map, because then, there is no need to check the
    # type of the profileable.
    # But, this makes no sense at the moment, since the profileable objects have
    # to be loaded anyway, since we need the title of the profileables.
    #
    @large_map_address_fields = @users_map_profile_fields + @groups_map_profile_fields
  end


  # These methods collect the address fields for displaying the large map
  # on group pages.
  #
  # https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Controller
  #
  def descendant_groups_map_profile_fields
    @descendant_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.descendant_group_ids )
  end
  def child_groups_map_profile_fields
    @child_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.child_group_ids )
  end
  def own_map_profile_fields
    @own_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.id )
  end
  def users_map_profile_fields
    @users_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: @members.collect { |member| member.id } ).includes(:profileable)
  end


  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Group', 'Page']
  end


  def redirect_to_group_tab
    redirect_to current_tab_path(@group)
  end

end
