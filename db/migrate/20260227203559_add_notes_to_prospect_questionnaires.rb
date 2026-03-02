class AddNotesToProspectQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    add_column :prospect_questionnaires, :notes, :text
  end
end
