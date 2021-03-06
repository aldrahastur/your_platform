concern :EventGroups do

  included do
    belongs_to :group

    def group
      super || parent_groups.first
    end
  end

  def self.move_event_to_group(event_id, group_id)
    Event.find(event_id).move_to Group.find(group_id)
  end

  def move_to(group)
    self.group_id = group.id
    self.save
  end

  def admins_of_self_and_ancestors
    (super + group.admins_of_self_and_ancestors).uniq
  end

  class_methods do
    def find_all_by_group(group)
      group.events_of_self_and_subgroups.order('start_at')
    end
  end
end