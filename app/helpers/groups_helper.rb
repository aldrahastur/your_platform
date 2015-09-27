module GroupsHelper
  
  def groups_of_user_table( user )
    content_tag :table, :class => "user_groups" do
      content_tag :tr do
        
        # first column:
        c = content_tag :td do
          content_tag :ul do
            
            corporation_groups = user.current_corporations
            if corporation_groups
              corporation_groups.collect do |group|
                sub_group_membership_lis( user: user, group: group, indent: 0, max_indent: 3 )
              end.join.html_safe
            end
            
          end
        end

        # second column:
        c += content_tag( :td ) do
          content_tag :ul do
            
            Group.find_non_corporations_branch_groups_of( user ).collect do |group|
              membership_li( user, group )
            end.join.html_safe
            
          end
        end
      end
    end.html_safe
  end
  
  def cached_groups_of_user_table(user)
    Rails.cache.fetch([user, 'groups_of_user_table'], expires_in: 1.week) { groups_of_user_table(user) }
  end
  
  private

  def membership_li( user, group )
    content_tag :li do
      link_to group.extensive_name, group
    end
  end

  def sub_group_membership_lis( options = {} )
    c = ""
    c += membership_li( options[ :user ], options[ :group ] )
    sub_groups_where_user_is_member = options[ :group ].child_groups & options[ :user ].groups.to_a
    current_indent = options[ :indent ] + 1
    max_indent = options[ :max_indent ]
    current_indent = max_indent if current_indent > max_indent
    c += "<ul>" if current_indent < max_indent
    c += sub_groups_where_user_is_member.collect do |sub_group|
      sub_group_membership_lis( user: options[ :user ], group: sub_group, 
                                indent: current_indent, max_indent: options[ :max_indent ] )
    end.join
    c += "</ul>" if current_indent < max_indent
    return c.html_safe
  end

end
