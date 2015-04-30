class RootController < ApplicationController
  
  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_sign_in_if_needed, :find_and_authorize_page

  def index
    current_user.try(:update_last_seen_activity, "sieht sich die Startseite an", @page)
    @navable = @page
    @blog_entries = @page.blog_entries
    
    render "pages/show"
  end
  
  
private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end
  
  # If a public website exists, which is not just a redirection, then signed-out
  # users are shown the public website.
  #
  # If no public website exists, the users are shown sign-in form.
  # 
  def redirect_to_sign_in_if_needed
    unless current_user or @need_setup
      if Page.public_website_present?
        redirect_to Page.public_root
      else
        redirect_to sign_in_path
      end
    end
  end

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    reload_ability
    authorize! :show, @page
  end
  
end
