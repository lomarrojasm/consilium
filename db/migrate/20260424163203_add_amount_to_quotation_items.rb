class AddAmountToQuotationItems < ActiveRecord::Migration[8.0]
  def change
    add_column :quotation_items, :amount, :decimal, precision: 15, scale: 2
  end
end
