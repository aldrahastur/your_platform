module VueHelper

  # Display a list of posts and comments with a vue component.
  #
  # show_public_badges: Whether to show a badge indicating whether the
  #   post is to be published on the public website.
  #
  def vue_posts(posts, show_public_badges: false)
    content_tag :vue_post_list_group, "", {
      ':posts': posts.where.not(author_user_id: nil).includes({author: [:avatar_attachments]}, :attachments, {comments: [author: [:avatar_attachments]]}, :group, :parent_groups, :parent_events).collect { |post|
        post.as_json.merge({
          author: post.author.as_json.merge({
            path: (polymorphic_path(post.author) if can?(:read, post.author))
          }),
          attachments: post.attachments.as_json,
          comments: post.comments.collect { |comment|
            comment.as_json.merge({
              author: comment.author
            })
          },
          can_comment: can?(:create_comment, post),
          groups: (post.parent_groups + [post.group] - [nil]).as_json,
          events: post.parent_events.as_json,
          can_update_publish_on_public_website: can?(:update_public_website_publication, post)
        })
      }.to_json,
      send_icon: send_icon,
      ':current_user': current_user.to_json,
      ':show_public_badges': show_public_badges.to_b.to_json
    }
  end

  def vue_create_post_form(initial_post: nil, sent_via: nil, show_send_via_email_toggle: false, suggested_groups: Group.none, send_via_email: nil, show_publish_on_website_toggle: false, parent_group: nil)
    content_tag :vue_create_post_form, "", {
      camera_icon: camera_icon,
      send_icon: send_icon,
      sent_via: sent_via,
      ':parent_group': parent_group.to_json,
      ':initial_post': (initial_post.as_json.merge({
        attachments: initial_post.attachments.as_json,
        parent_groups: initial_post.parent_groups.includes(:avatar_attachments, :flags).collect { |group|
          group.as_json.merge({
            title: group.title,
            avatar_path: group.avatar_path
          })
        }
      }).to_json if initial_post),
      ':suggested_groups': suggested_groups.includes(:avatar_attachments, :flags).collect { |group|
        group.as_json.merge({
          title: group.title,
          avatar_path: group.avatar_path
        })
      }.to_json,
      ':show_send_via_email_toggle': show_send_via_email_toggle.to_json,
      ':initial_send_via_email': send_via_email.to_json,
      ':show_publish_on_website_toggle': show_publish_on_website_toggle.to_json,
    }
  end

  def vue_semester_calendar_events(semester_calendar:, events: nil)
    content_tag :vue_semester_calendar_events, "", {
      ':initial_events': (events || semester_calendar.events)
        .select { |event| can? :read, event }
        .collect { |event|
          event.as_json(methods: [:aktive, :philister]).merge({
            attendees_count: event.attendees.count,
            can_create_post: can?(:create_post, event)
          })}
        .to_json,
      ':editable': can?(:update, semester_calendar).to_json,
      ':group': semester_calendar.group.to_json,
      default_location: semester_calendar.group.postal_address,
      ':semester_calendar': semester_calendar.to_json,
      ':next_semester_calendar': semester_calendar.next.to_json,
      camera_icon: camera_icon
    }
  end

end