# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## CAMPOS PERSONALIZADOS

      t.string :first_name, null: false, default: "" # Nombre
      t.string :last_name, null: false, default: ""  # Apellido
      t.string :username               # Usuario (opcional)
      t.string :job_title                            # Cargo (ej: Gerente de Ventas)
      t.integer :role, default: 0                    # Rol (0: user, 1: admin)
      t.boolean :active, default: true               # Para desactivar usuarios sin borrarlos


      ## 3. Relación con el Cliente (Empresa)
      # null: true permite crear un SuperAdmin inicial sin cliente si es necesario, 
      # o manejar la lógica de invitación sin fallar antes de asignar.
      t.references :client, null: true, foreign_key: true


      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Invitable (ESTO ES LO NUEVO)
      t.string   :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit
      t.integer  :invited_by_id
      t.string   :invited_by_type
      t.index    :invitation_token, unique: true

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

    # CORRECCIÓN AQUÍ: Agregamos el índice de unicidad para username (si lo usas)
    add_index :users, :username, unique: true
  end
end
