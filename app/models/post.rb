class Post < ActiveRecord::Base
  attr_accessible :author_user_id, :external_author, :group_id, :sent_at, :sticky, :subject, :text if defined? attr_accessible
  
  belongs_to :group
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'
  has_many :comments, as: :commentable
  
  
  def title
    subject
  end

  # This allows to set the author either as email or as email string.
  #
  def author=(author)
    if author.kind_of? User
      super(author)
    elsif author.kind_of? String
      users_by_email = User.find_all_by_email(author) 
      user_by_email = users_by_email.first if users_by_email.count == 1
      if user_by_email
        super(user_by_email)
      else
        self.external_author = author
      end
    end
  end
  def author
    super || external_author
  end

  # In order to do the encoding conversion properly,
  # we have to find out the former encoding from the mail header.
  # 
  # parameter: Mail object
  # #<Mail::Part:-570274288, Multipart: false, Headers: <Content-Type: text/html; charset=windows-1252>, 
  #   <Content-Transfer-Encoding: quoted-printable>>
  # 
  def self.mail_encoding(mail)
    mail.inspect.to_s.scan(/.charset=(.*)>./)[0][0].split(">").first if mail
  end

  
  # This returns the text attribute, i.e. the message body, without html tags,
  # which could be used in block quotes, where only an excerpt of the message
  # is shown. (Use this to avoid opened but not closed html tags.)
  #
  def text_without_html_tags
    # http://stackoverflow.com/questions/7414267/strip-html-from-string-ruby-on-rails
    HTML::FullSanitizer.new.sanitize(self.text)
  end


  # Delivering Post as Email to All Group Members
  # ==========================================================================================
  
  def notify_recipients
    send_as_email_to_recipients
  end
  def send_as_email_to_recipients(recipients = nil)
    recipients ||= group.members

    # We want only one recipient in the 'to' field of each email.
    # Thus, deliver separately.
    #
    successfully_delivered_to = recipients.select do |recipient|
      unless recipient.email_does_not_work?
        PostMailer.post_email(text, [recipient], email_subject, author, group, self).deliver
      end
    end
    
    logger.info "Sent Post email to #{successfully_delivered_to.count} recipients."
    return successfully_delivered_to.count
  end
  
  def email_subject
    subject.include?("[") ? subject : "[#{group.name}] #{subject}"
  end
  

  # Each post may be delivered to all group members via email. ("Group Mail Feature").
  # This method returns the message to deliver to the group members.
  # This is done separately (i.e. one user at a time) in order to (a) not reveal the 
  # email addresses, and (b) avoid being caught by a spam filter.
  #
  # Calling this method will produce, *not deliver* the mail messages.
  # 
  def messages_to_deliver_to_mailing_list_members
    self.group.descendant_users.collect do |user|
      message_for_email_delivery_to_user(user)
    end
  end

  # This method returns the modified subject, which is used by the Group Mail Feature.
  # Give a post subject 'My Fancy Subject" and the post's group's name being "Test Group",
  # this mehtod returns "[Test Group] My Fancy Subject". 
  #
  # If the subject already contains the prefix, like in "Re: [Test Group] My Fancy Subject", 
  # of cause, the prefix isn't added, twice.
  #
  def modified_subject
    prefix = "[#{self.group.name}] "
    if self.subject.include? prefix
      return subject
    else
      return prefix + subject
    end
  end

  # This method returns a mail footer, which may be added to the messages delivered via
  # email. The footer contains, e.g. a link to the group's site.
  #
  def mailing_list_footer
    "\n\n\n" + 
      "_____________________________________\n" +
      I18n.t(:this_message_has_been_deliverd_through_mailing_list, group_name: self.group.name ) + "\n" +
      self.group.url + "\n"
  end

  # This method returns the modified message, ready for delivery via email
  # to the specified user.
  #
  def message_for_email_delivery_to_user( user )

    # use the stored message as template
    message = self.entire_message
    
    # modify the subject according to the group's name
    message.subject = self.modified_subject

    # modify the envelope_to field, but keep the to field as it is.
    # Thereby, the group mail address is shown in the mail programs
    # as recipient.
    message.smtp_envelope_to = user.email

    # add the footer for each part
    message.add_to_body self.mailing_list_footer
    
    return message
  end

end