class CreateFinancialAccruals < ActiveRecord::Migration[8.0]
  def change
    create_table :financial_accruals do |t|
      t.references :project, null: false, foreign_key: true
      t.string :stage_name
      t.string :concept_name
      t.decimal :amount
      t.date :accrued_date
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
