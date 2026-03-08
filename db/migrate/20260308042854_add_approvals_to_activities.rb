class AddApprovalsToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :user_approved, :boolean
    add_column :activities, :user_approved_at, :datetime
    add_column :activities, :admin_approved, :boolean
    add_column :activities, :admin_approved_at, :datetime
    add_column :activities, :evidence_uploaded_at, :datetime
  end
end
