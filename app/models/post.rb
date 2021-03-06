class Post < ApplicationRecord

  belongs_to :group
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'

  has_dag_links ancestor_class_names: %w(Group User Page Event), descendant_class_names: %w(), link_class_name: 'DagLink'

  has_many :attachments, as: :parent, dependent: :destroy

  has_many :deliveries, class_name: 'PostDelivery', dependent: :destroy

  include Commentable
  include PostDeliveryReport
  include PostDrafts
  include Flags

  scope :public_post, -> { where(publish_on_public_website: true) }

  def title
    return subject if subject.present?
    return attachments.collect(&:title).join(", ") if attachments.any?
    return ActionController::Base.helpers.strip_tags(text).first(100) if text.present?
  end

  def mail_to(user)
    PostDelivery.where(post_id: self.id, user_id: user.id).first_or_create
  end

  def groups
    Group.where(id: group_id).or(Group.where(id: parent_groups))
  end

end
