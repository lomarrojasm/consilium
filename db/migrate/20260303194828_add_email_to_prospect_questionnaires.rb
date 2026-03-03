class AddEmailToProspectQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    add_column :prospect_questionnaires, :email, :string
  end
end
