class ChangeConceptNameToText < ActiveRecord::Migration[8.0]
  def up
    # Cambia :nombre_de_tu_tabla por la tabla real (ej. :payments, :accruals, etc.)
    change_column :financial_accruals, :concept_name, :text
  end

  def down
    change_column :financial_accruals, :concept_name, :string
  end
end
