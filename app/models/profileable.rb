#
# This module allows to mark a model (User, Group, ...) as profileable, i.e. have profile fields.
#
# The inclusion of this module into ActiveRecord::Base is done in
# config/initializers/active_record_navable_extension.rb.
#

module Profileable
  def has_profile_fields( options = {} )
    is_profileable(options)
  end

  def is_profileable( options = {} )
    @profile_section_titles = options[:profile_sections] || default_profile_section_titles
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
    has_many :address_profile_fields, -> { where type: 'ProfileFieldTypes::Address' }, class_name: 'ProfileFieldTypes::Address', as: :profileable, dependent: :destroy, autosave: true
    
    include InstanceMethodsForProfileables
  end
  
  def default_profile_section_titles
    [:contact_information, :about_myself, :study_information, :career_information, 
     :organizations, :bank_account_information, :description]
  end
  def profile_section_titles 
    @profile_section_titles
  end  

  module InstanceMethodsForProfileables
    
    def email
      @email ||= cached { profile_fields_by_type("ProfileFieldTypes::Email").first.try(:value) }
    end
    def email=( email )
      @email = nil
      @email_profile_field = profile_fields_by_type( "ProfileFieldTypes::Email" ).first unless @email_profile_field
      @email_profile_field = profile_fields.build( type: "ProfileFieldTypes::Email", label: "email" ) unless @email_profile_field
      @email_profile_field.value = email
    end
    def email_does_not_work?
      email_needs_review? or email_empty?
    end
    def email_needs_review?
      profile_fields_by_type("ProfileFieldTypes::Email").review_needed.count > 0
    end
    def email_empty?
      not email.present?
    end
    
    def profile
      @profile ||= Profile.new(self)
    end

    def profile_section_titles
      self.class.profile_section_titles
    end
    
    def profile_sections
      self.profile.sections
    end
    
    def profile_fields_by_type( type_or_types )
      profile_fields.where( type: type_or_types )
    end
    
  end
 
end
