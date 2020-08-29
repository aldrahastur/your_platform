require 'spec_helper'

describe ReceivedPostMail do

  let(:sender_user) { create :user }
  let(:recipient_group) {
    group = create :group
    group.profile_fields.create(type: 'ProfileFields::MailingListEmail', value: 'example-group@example.com')
    group
  }
  let(:message) {
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: Test Mail\n" +
    "Message-ID: <beiNgai7OhZael0chach2xa9Kekirietiy6yuc3uu5Thah8I@example.com>\n\n" +
    "This is a simple text message."
  }
  let(:mail) { ReceivedPostMail.new(message) }

  let(:email_looped_message) {
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: Test Mail\n" +
    "Message-ID: <uD3saic8Jiexah5aajee9ieba8aiGae6aaph7faelae7Mah7@example.com>\n\n" +
    "This is a simple text message.\n\n" +
    "__________\n" +
    "Sent through mail group."
  }
  let(:email_looped_message_with_modified_subject) {
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: [#{recipient_group.name}] Test Mail\n" +
    "Message-ID: <uD3saic8Jiexah5aajee9ieba8aiGae6aaph7faelae7Mah7@example.com>\n\n" +
    "This is a simple text message.\n\n" +
    "__________\n" +
    "Sent through mail group."
  }

  describe "#deliver_rejection_emails" do
    before { mail.store_as_posts_when_authorized }
    subject { mail.deliver_rejection_emails }

    it "should send a rejection email to the sender user" do
      subject
      rejection_mail = ActionMailer::Base.deliveries.last
      rejection_mail.to.should == [sender_user.email]
      rejection_mail.subject.should == "Re: Test Mail"
      rejection_mail.body.should include recipient_group.name
      rejection_mail.body.should include "You are not authorized"
    end

    # # TODO: Reactivate when using smtp-envelope-to
    # # See: https://trello.com/c/DnWQTmuj/919, https://trello.com/c/OOauI77I/918
    # #
    # describe "when the recipient could not be determined" do
    #   let(:message) {
    #     "From: #{sender_user.name} <#{sender_user.email}>\n" +
    #     "To: unknown.recipient@example.com\n" +
    #     "Subject: Test Mail\n\n" +
    #     "This is a simple text message."
    #   }
    #   let(:mail) { ReceivedPostMail.new(message) }
    #
    #   it "should send a rejection email to the sender user" do
    #     subject
    #     rejection_mail = ActionMailer::Base.deliveries.last
    #     rejection_mail.to.should == [sender_user.email]
    #     rejection_mail.subject.should == "Re: Test Mail"
    #     rejection_mail.body.should include "unknown.recipient@example.com"
    #     rejection_mail.body.should include "Recipient could not be determined"
    #   end
    # end
  end

  describe "#store_as_posts" do
    subject { mail.store_as_posts }

    describe "when the user is authorized to create a post in that group" do
      before { recipient_group << sender_user }

      its(:count) { should == 1 }
      describe "#first" do
        subject { mail.store_as_posts.first }

        it { should be_kind_of Post }
        its(:id) { should be_present }
        its(:group) { should == recipient_group }
        its(:author) { should == sender_user }
        its(:subject) { should == "Test Mail" }
        its(:text) { should == "This is a simple text message." }
        its(:content_type) { should == "text" }
        its(:message_id) { should be_present }

        describe "for an unknown sender" do
          before { recipient_group.mailing_list_sender_filter = :open; recipient_group.save }
          let(:message) {
            "From: Unknown Sender <unknown@example.com>\n" +
            "To: #{recipient_group.email}\n" +
            "Subject: Test Mail\n\n" +
            "This is a simple text message."
          }
          let(:mail) { ReceivedPostMail.new(message) }

          it "should store the author as string" do
            subject.external_author.should == "Unknown Sender <unknown@example.com>"
          end
        end
      end

      it "should not import the same email twice" do
        Post.destroy_all
        mail.store_as_posts
        Post.count.should == 1
        mail.store_as_posts
        Post.count.should == 1
      end

      it "should not import the same email twice if it came through an email loop with different message id" do
        # In this scenario, a recipient address redirects to the mail group address creating an email loop.
        # The mail system should prevent such email loops by comparing subject, sender and time.
        Post.destroy_all
        @posts_created_in_first_run = ReceivedPostMail.new(message).store_as_posts
        Post.count.should == 1
        @posts_created_in_second_run = ReceivedPostMail.new(email_looped_message).store_as_posts
        Post.count.should == 1

        @posts_created_in_first_run.count.should == 1
        @posts_created_in_second_run.count.should == 0

        @posts_created_in_first_run.collect { |post| post.class.name }.should_not include "NilClass"
        @posts_created_in_first_run.collect { |post| post.class.name }.uniq.should == ["Post"]
      end

      it "should not import the same email twice if it came through an email loop with different message id, even if the subject has been modified" do
        # In this scenario, a recipient address redirects to the mail group address creating an email loop.
        # The mail system should prevent such email loops by comparing subject, sender and time.
        Post.destroy_all
        @posts_created_in_first_run = ReceivedPostMail.new(message).store_as_posts
        Post.count.should == 1
        @posts_created_in_second_run = ReceivedPostMail.new(email_looped_message_with_modified_subject).store_as_posts
        Post.count.should == 1

        @posts_created_in_first_run.count.should == 1
        @posts_created_in_second_run.count.should == 0

        @posts_created_in_first_run.collect { |post| post.class.name }.should_not include "NilClass"
        @posts_created_in_first_run.collect { |post| post.class.name }.uniq.should == ["Post"]
      end

      it "should not import the post if the recipient email is not a mailing list" do
        recipient_group.profile_fields.where(type: 'ProfileFields::MailingListEmail').destroy_all
        recipient_group.profile_fields.create(type: 'ProfileFields::Email', value: 'example-group@example.com')

        Post.destroy_all
        subject
        Post.count.should == 0
      end
    end

    describe "when the sender user is not authorized to create a post in the recipient group" do
      its(:count) { should == 0 }
    end
  end

end