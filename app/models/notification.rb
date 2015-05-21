# These objects store notifications for users, for example
# for posts or comments. Each user can choose his own notification
# policy, i.e. in which intervals notifications should be sent
# to him.
#
#     create_table :notifications do |t|
#       t.integer :recipient_id
#       t.integer :author_id
#       t.string :reference_url
#       t.string :reference_type
#       t.integer :reference_id
#       t.string :message
#       t.text :text
#       t.datetime :sent_at
#       t.datetime :read_at
# 
#       t.timestamps null: false
#     end
#
class Notification < ActiveRecord::Base
  attr_accessible :recipient_id, :author_id, :reference_url, :reference_type, :reference_id, :message, :text, :sent_at
  
  belongs_to :recipient, class_name: 'User'
  belongs_to :author, class_name: 'User'
  belongs_to :reference, polymorphic: true
  
  after_create :create_notification_job
  
  scope :sent, -> { where.not(sent_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :upcoming, -> { where('sent_at IS NULL AND read_at IS NULL') }
  
  # Creates all notifications for users that should
  # be notified about this post.
  #  
  # Options:
  #   - sent_at    In order to mark a notification as already sent.
  #
  def self.create_from_post(post, options = {})
    post.group.members.collect do |group_member|
      locale = group_member.locale
      message = post.subject if not post.text.start_with?(post.subject)
      message ||= I18n.t(:has_posted_a_new_message, user_title: post.author.title, locale: locale) if post.author.kind_of?(User)
      message ||= I18n.t(:a_new_message_has_been_posted, locale: locale)
      
      self.create(
        recipient_id:   group_member.id,
        author_id:      post.author.kind_of?(User) ? post.author.id : nil,
        reference_url:  post.url,
        reference_type: post.class.name,
        reference_id:   post.id,
        message:        message,
        text:           post.text,
        sent_at:        options[:sent_at]
      )
    end
  end
  
  # Schedule a notification job with resque.
  #
  def create_notification_job
    NotificationJob.set(wait_until: self.send_at).perform_later
  end
  
  # Calculate when this notification should be sent to the user
  # via email.
  #
  # 1. If the recipient wants to be notified instantly, just send it
  #    in a couple of seconds.
  # 2. If the recipient wants to be notified in letter bundles,
  #    wait 10 minutes. Then, if new notifications have been
  #    created, wait for those. Otherwise, send it.
  # 3. If the recipient wants to be notified once a day, 
  #    do it at 6pm.
  #   
  def send_at
    case self.recipient.notification_policy
    when :instantly
      15.seconds.from_now
    when :letter_bundle
      Time.zone.now + self.class.letter_bundle_wait_time.min
    else # including :daily
      if Time.zone.now.hour > 18
        Time.zone.now.change(hour: 18) + 1.day
      else
        Time.zone.now.change(hour: 18)
      end
    end
  end
  
  # Find all notifications that are due to be sent via email.
  # 
  def self.due
    self.upcoming.joins(:recipient).where(
      # Notifications that should be sent instantly, are always due.
      "(users.notification_policy = 'instantly')" +
      
      # Notifications that are to be sent daily, are due at 6 pm,
      # but only those that have been sent before. Otherwise, the user
      # will get multiple emails after 6 pm.
      " OR " + (Time.zone.now >= Time.zone.now.change(hour: 18) ? "((users.notification_policy = 'daily' OR users.notification_policy is null) AND notifications.created_at < ?)" : "? is null") + 
      
      # Notifications that are to be sent in letter bundles, 
      # are due under the following conditions:
      # * The last upcoming notification for that user has been
      #   created longer than 10 minutes ago.
      # * The first upcoming notification for that user has been
      #   created longer than 1 hour ago.
      " OR (users.notification_policy = 'letter_bundle' AND users.id IN (?))", 
      
      Time.zone.now.change(hour: 18),
      self.user_ids_where_letter_bundle_is_due
    )
  end

  # Notifications that are to be sent in letter bundles, 
  # are due under the following conditions:
  # * The last upcoming notification for that user has been
  #   created longer than 10 minutes ago.
  # * The first upcoming notification for that user has been
  #   created longer than 1 hour ago.
  #
  def self.user_ids_where_letter_bundle_is_due
    User.where(notification_policy: 'letter_bundle').includes(:notifications).select { |user|
      (user.notifications.upcoming.order('created_at asc').pluck(:created_at).last < Time.zone.now - self.letter_bundle_wait_time.min) or
      (user.notifications.upcoming.order('created_at asc').pluck(:created_at).first < Time.zone.now - self.letter_bundle_wait_time.max)
    }.map(&:id)
  end
  
  # Find all upcoming notifications for a given user.
  def self.upcoming_by_user(user)
    self.upcoming.where(recipient_id: user.id)
  end
  
  # Deliver the notifications.
  #
  def self.deliver
    User.where(id: self.upcoming.pluck(:recipient_id)).collect do |recipient|
      self.deliver_for_user(recipient)
    end
  end
  
  # Deliver all upcoming notifications for a certain user.
  #
  # The notification mail is *not* sent:
  #   * if the user has no upcoming notifications
  #   * if the user has no account
  #   * if the user is no beta tester (TODO: notifications for all)
  #
  def self.deliver_for_user(user)
    notifications = self.upcoming_by_user(user)
    if notifications.count > 0 and user.account and user.beta_tester?
      NotificationMailer.notification_email(user, notifications).deliver_now
      notifications.each { |n| n.update_attribute(:sent_at, Time.zone.now) }
    end
  end
  
  # The time that notifications are delayed when they should be sent
  # as letter bundles.
  #
  # The notification systems waits the time period specified here
  # for new notifications to append before sending a notifications
  # email.
  #
  # For example, `10.minutes..1.hour` means that the system will at 
  # least 10 minutes, but not longer than an hour to send a 
  # notification after it has been created.
  #
  def self.letter_bundle_wait_time
    10.minutes..1.hour
  end

end