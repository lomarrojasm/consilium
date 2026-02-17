class AddDetailsToActivities < ActiveRecord::Migration[8.0]
  def change
    # 1. Campos de Seguimiento
    add_column :activities, :completed_day, :integer # Día del mes en que se completó (1-31)
    add_column :activities, :area, :string           # Integral, Dirección, Finanzas, etc.

    # 2. Campos de Costos Totales ($)
    add_column :activities, :activity_cost, :decimal, precision: 10, scale: 2
    add_column :activities, :leader_cost,   :decimal, precision: 10, scale: 2
    add_column :activities, :senior_cost,   :decimal, precision: 10, scale: 2
    add_column :activities, :analyst_cost,  :decimal, precision: 10, scale: 2

    # 3. Campos de Tarifas ($ por hora)
    add_column :activities, :leader_rate,   :decimal, precision: 10, scale: 2
    add_column :activities, :senior_rate,   :decimal, precision: 10, scale: 2
    add_column :activities, :analyst_rate,  :decimal, precision: 10, scale: 2

    # 4. Campos de Horas (Tiempo)
    add_column :activities, :leader_hours,  :float
    add_column :activities, :senior_hours,  :float
    add_column :activities, :analyst_hours, :float
    
    # Índices para búsquedas rápidas
    add_index :activities, :area
  end
end