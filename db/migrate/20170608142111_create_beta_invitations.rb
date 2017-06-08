class CreateBetaInvitations < ActiveRecord::Migration
  def change
    create_table :beta_invitations do |t|
      t.integer :beta_id
      t.integer :inviter_id
      t.integer :invitee_id

      t.timestamps null: false
    end
  end
end
