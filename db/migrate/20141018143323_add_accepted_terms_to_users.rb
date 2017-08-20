class AddAcceptedTermsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :accepted_terms, :string
    add_column :users, :accepted_terms_at, :datetime
  end
end
