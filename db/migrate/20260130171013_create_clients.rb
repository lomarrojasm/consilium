class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      # 1. Identificación
      t.string :company_name, null: false # Obligatorio
      t.string :corporate_regime
      t.string :trade_name
      t.string :rfc
      t.string :tax_regime
      t.string :type_taxpayer
      t.string :industry
      t.string :country
      
      # Dirección Fiscal
      t.string :tax_street
      t.string :tax_no_ext
      t.string :tax_no_int
      t.string :tax_suburb
      t.string :tax_cp
      t.string :tax_city
      t.string :tax_town_hall
      
      # Dirección Operativa
      t.string :oper_street
      t.string :oper_no_ext
      t.string :oper_no_int
      t.string :oper_suburb
      t.string :oper_cp
      t.string :oper_city
      t.string :oper_town_hall

      # 2. Dimensionamiento
      t.string :operation_year
      t.string :total_employee
      t.string :total_location
      t.string :product_service

      # 3. Contactos clave
      t.string :sponsor_name
      t.string :sponsor_position
      t.string :sponsor_cel
      t.string :sponsor_email

      t.string :legal_representative_name
      t.string :legal_representative_position
      t.string :legal_representative_cel
      t.string :legal_representative_email

      t.string :operation_name
      t.string :operation_position
      t.string :operation_cel
      t.string :operation_email # Corregí 'operation' a 'operation_email' para consistencia

      t.string :finance_accounting_name # Corregí 'accouting'
      t.string :finance_accounting_position
      t.string :finance_accounting_cel
      t.string :finance_accounting_email

      t.string :rrhh_name
      t.string :rrhh_position
      t.string :rrhh_cel
      t.string :rrhh_email

      t.string :comercial_name
      t.string :comercial_position
      t.string :comercial_cel
      t.string :comercial_email

      # 4. Sistemas (Eliminé dobles guiones bajos __)
      t.string :erp_system
      t.string :accounting_system
      t.string :rrhh_system
      t.string :crm_system
      t.string :storage_system

      # 5. Contexto del Proyecto
      t.text :main_issue
      t.text :project_objective # Corregí 'proyect_objetive'
      t.text :deadline

      # 6. Coordinación
      t.string :internal_responsible_name
      t.string :internal_responsible_contact

      # 7. Redes Sociales
      t.text :social_network
      t.string :web_page

      t.timestamps
    end
  end
end