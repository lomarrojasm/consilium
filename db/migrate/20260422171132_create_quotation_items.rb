class CreateQuotationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quotation_items do |t|
      t.references :quotation, null: false, foreign_key: true
      t.references :financial_accrual, null: false, foreign_key: true

      t.timestamps
    end
  end
end
