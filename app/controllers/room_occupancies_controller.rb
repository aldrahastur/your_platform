class RoomOccupanciesController < ApplicationController

  expose :group
  expose :room, -> { group if group.kind_of? Groups::Room }
  expose :occupancies, -> { room.occupancies.order(valid_from: :desc).collect { |membership|
    membership.as_json.merge({
      occupant_title: (membership.user.title if can?(:read_name, membership.user)),
      occupant: (membership.user if can?(:read, membership.user))
    })
  } }
  expose :scope, -> { room.parent_groups.try(:first) }
  expose :corporation, -> { room.corporation }
  expose :redirect_to_url, -> { params[:redirect_to_url] || corporation_accommodations_path(corporation_id: corporation.id) }

  def index
    authorize! :read, room

    set_current_title room.title
    set_current_navable room
    set_current_tab :contacts
  end

  def new
    authorize! :update_accommodations, corporation

    set_current_title room.title
    set_current_navable scope
    set_current_tab :contacts
  end

end