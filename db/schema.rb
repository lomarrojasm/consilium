# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_15_032744) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "completed"
    t.bigint "stage_id", null: false
    t.integer "month"
    t.integer "week"
    t.string "document_ref"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "completed_day"
    t.string "area"
    t.decimal "activity_cost", precision: 10, scale: 2
    t.decimal "leader_cost", precision: 10, scale: 2
    t.decimal "senior_cost", precision: 10, scale: 2
    t.decimal "analyst_cost", precision: 10, scale: 2
    t.decimal "leader_rate", precision: 10, scale: 2
    t.decimal "senior_rate", precision: 10, scale: 2
    t.decimal "analyst_rate", precision: 10, scale: 2
    t.float "leader_hours"
    t.float "senior_hours"
    t.float "analyst_hours"
    t.bigint "user_id", null: false
    t.index ["area"], name: "index_activities_on_area"
    t.index ["stage_id"], name: "index_activities_on_stage_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "corporate_regime"
    t.string "trade_name"
    t.string "rfc"
    t.string "tax_regime"
    t.string "type_taxpayer"
    t.string "industry"
    t.string "country"
    t.string "tax_street"
    t.string "tax_no_ext"
    t.string "tax_no_int"
    t.string "tax_suburb"
    t.string "tax_cp"
    t.string "tax_city"
    t.string "tax_town_hall"
    t.string "oper_street"
    t.string "oper_no_ext"
    t.string "oper_no_int"
    t.string "oper_suburb"
    t.string "oper_cp"
    t.string "oper_city"
    t.string "oper_town_hall"
    t.string "operation_year"
    t.string "total_employee"
    t.string "total_location"
    t.string "product_service"
    t.string "sponsor_name"
    t.string "sponsor_position"
    t.string "sponsor_cel"
    t.string "sponsor_email"
    t.string "legal_representative_name"
    t.string "legal_representative_position"
    t.string "legal_representative_cel"
    t.string "legal_representative_email"
    t.string "operation_name"
    t.string "operation_position"
    t.string "operation_cel"
    t.string "operation_email"
    t.string "finance_accounting_name"
    t.string "finance_accounting_position"
    t.string "finance_accounting_cel"
    t.string "finance_accounting_email"
    t.string "rrhh_name"
    t.string "rrhh_position"
    t.string "rrhh_cel"
    t.string "rrhh_email"
    t.string "comercial_name"
    t.string "comercial_position"
    t.string "comercial_cel"
    t.string "comercial_email"
    t.string "erp_system"
    t.string "accounting_system"
    t.string "rrhh_system"
    t.string "crm_system"
    t.string "storage_system"
    t.text "main_issue"
    t.text "project_objective"
    t.text "deadline"
    t.string "internal_responsible_name"
    t.string "internal_responsible_contact"
    t.text "social_network"
    t.string "web_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_conversations_on_client_id"
    t.index ["recipient_id"], name: "index_conversations_on_recipient_id"
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "messaged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "actor_type", null: false
    t.bigint "actor_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.datetime "read_at"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_notifications_on_actor"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "project_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recipient_id"
    t.index ["project_id"], name: "index_project_comments_on_project_id"
    t.index ["recipient_id"], name: "index_project_comments_on_recipient_id"
    t.index ["user_id"], name: "index_project_comments_on_user_id"
  end

  create_table "project_members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "added_by_id"
    t.index ["added_by_id"], name: "index_project_members_on_added_by_id"
    t.index ["project_id"], name: "index_project_members_on_project_id"
    t.index ["user_id"], name: "index_project_members_on_user_id"
  end

  create_table "projects", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.text "details"
    t.date "start_date"
    t.date "end_date"
    t.decimal "budget", precision: 10
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "stages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "project_id", null: false
    t.integer "status"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_stages_on_project_id"
  end

  create_table "timeline_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "user_id"
    t.string "resource_type", null: false
    t.bigint "resource_id", null: false
    t.string "action_type"
    t.text "details"
    t.datetime "happened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_timeline_logs_on_client_id"
    t.index ["resource_type", "resource_id"], name: "index_timeline_logs_on_resource"
    t.index ["user_id"], name: "index_timeline_logs_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "username"
    t.string "job_title"
    t.integer "role", default: 0
    t.boolean "active", default: true
    t.bigint "client_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "stages"
  add_foreign_key "activities", "users"
  add_foreign_key "conversations", "clients"
  add_foreign_key "conversations", "users", column: "recipient_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "project_comments", "projects"
  add_foreign_key "project_comments", "users"
  add_foreign_key "project_comments", "users", column: "recipient_id"
  add_foreign_key "project_members", "projects"
  add_foreign_key "project_members", "users"
  add_foreign_key "project_members", "users", column: "added_by_id"
  add_foreign_key "projects", "clients"
  add_foreign_key "projects", "users"
  add_foreign_key "stages", "projects"
  add_foreign_key "timeline_logs", "clients"
  add_foreign_key "timeline_logs", "users"
  add_foreign_key "users", "clients"
end
