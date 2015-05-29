require 'spec_helper'

describe ListExport do
  
  before do
    @group = create :group
    @corporation = create :corporation_with_status_groups
    @user = create :user
    @group.assign_user @user
    @corporation.status_groups.first.assign_user @user  # in order to give the @user a #title other than his #name.
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
    @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format
  end
  
  describe "birthday_list: " do
    before do
      @user.date_of_birth = "1925-09-28".to_date
      @user.save
      @next_birthday = @user.date_of_birth.change(:year => Time.zone.now.year)
      
      @list_export = ListExport.new(@group.members, :birthday_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Diesjähriger Geburtstag', 'Geburtsdatum', 'Aktuelles Alter' }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should include "Nachname;Vorname;Namenszusatz;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter" }
      it { should include "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};#{I18n.localize(@next_birthday)};#{I18n.localize(@user.date_of_birth)};#{@user.age}" }
    end
  end
  
  describe "address_list: " do
    before do
      @address1 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "Pariser Platz 1\n 10117 Berlin")
      @address1.update_column(:updated_at, "2014-06-20".to_datetime)
      @name_surrounding = @user.profile_fields.create(type: 'ProfileFieldTypes::NameSurrounding').becomes(ProfileFieldTypes::NameSurrounding)
      @name_surrounding.name_prefix = "Dr."
      @name_surrounding.name_suffix = "M.Sc."
      @name_surrounding.text_above_name = "Herrn"
      @name_surrounding.text_below_name = ""
      @name_surrounding.save
      @user.save
      
      @list_export = ListExport.new(@group.members, :address_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include('Nachname', 'Vorname', 'Namenszusatz', 'Postanschrift mit Name', 'Postanschrift', 
        'Letzte Änderung der Postanschrift am', 'Straße und Hausnummer', 'Postleitzahl (PLZ)', 'Stadt', 'Bundesland', 'Land', 'Länder-Kennzeichen', 'Persönlicher Titel',
        'Zeile über dem Namen', 'Zeile unter dem Namen', 'Text vor dem Namen', 'Text hinter dem Namen')
      }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should include "Nachname;Vorname;Namenszusatz;Postanschrift mit Name;Postanschrift;Letzte Änderung der Postanschrift am;Straße und Hausnummer;Postleitzahl (PLZ);Stadt;Bundesland;Land;Länder-Kennzeichen;Persönlicher Titel;Zeile über dem Namen;Zeile unter dem Namen;Text vor dem Namen;Text hinter dem Namen" }
      it { should include "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};\"Herrn\nDr. #{@user.name} M.Sc.\n#{@corporation.name}\nPariser Platz 1\n10117 Berlin\";\"#{@user.postal_address}\";20.06.2014;Pariser Platz 1;10117;Berlin;Berlin;Germany;DE;;Herrn;\"\";Dr.;M.Sc." }
    end
  end
  
  describe "#phone_list: " do
    before do
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFieldTypes::Phone', value: '123456').becomes(ProfileFieldTypes::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFieldTypes::Phone', value: '123457').becomes(ProfileFieldTypes::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFieldTypes::Phone', value: '01234').becomes(ProfileFieldTypes::Phone)
      @user.reload
      
      @list_export = ListExport.new(@group.members, :phone_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Namenszusatz', 'Beschriftung', 'Telefonnummer'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should ==
        "Nachname;Vorname;Namenszusatz;Beschriftung;Telefonnummer\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Phone;123456\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Mobile;01234\n"
      }
    end
  end
  
  describe "email list: " do
    before do
      @user.profile_fields.where(type: 'ProfileFieldTypes::Email').each { |field| field.destroy }
      @email_field_1 = @user.profile_fields.create(label: 'Email', type: 'ProfileFieldTypes::Email', value: 'foo@example.com').becomes(ProfileFieldTypes::Email)
      @email_field_2 = @user.profile_fields.create(label: 'Work Email', type: 'ProfileFieldTypes::Email', value: 'bar@example.com').becomes(ProfileFieldTypes::Email)
      @user.reload
      
      @list_export = ListExport.new(@group.members, :email_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Beschriftung', 'E-Mail-Adresse' }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should ==
        "Nachname;Vorname;Namenszusatz;Beschriftung;E-Mail-Adresse\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Email;foo@example.com\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Work Email;bar@example.com\n"
      }
    end
  end
  
  describe "member_development: " do
    before do
      @user.direct_memberships.destroy_all
      @corporation = create :corporation_with_status_groups
      @status_group_names = @corporation.status_groups.collect { |group| group.name }
      @date1 = "2006-12-01".to_datetime
      @date2 = "2007-02-02".to_datetime
      @date3 = "2008-04-01".to_datetime
      @membership1 = @corporation.status_groups[0].assign_user @user, at: @date1
      @membership2 = @membership1.move_to @corporation.status_groups[1], at: @date2
      @membership3 = @membership2.move_to @corporation.status_groups[2], at: @date3
      @user.reload
      @user_title_without_name = @user.title.gsub(@user.name, '').strip
      @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format
      
      @list_export = ListExport.new(@corporation, :member_development)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Geburtsdatum', 'Verstorben am', *@status_group_names }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should ==
        "Nachname;Vorname;Namenszusatz;Geburtsdatum;Verstorben am;Member Status 1;Member Status 2;Member Status 3\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};;;01.12.2006;02.02.2007;01.04.2008\n"
      }
    end
  end
  
  describe "name_list: " do
    before do
      @user.profile_fields.create(type: 'ProfileFieldTypes::AcademicDegree', value: "Dr. rer. nat.", label: :academic_degree)
      @user.profile_fields.create(type: 'ProfileFieldTypes::General', value: "Dr.", label: :personal_title)
      
      @list_export = ListExport.new(@group.members, :name_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Persönlicher Titel', 'Akademischer Grad' }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should include "Nachname;Vorname;Namenszusatz;Persönlicher Titel;Akademischer Grad" }
      it { should include "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Dr.;Dr. rer. nat." }
    end
  end
end