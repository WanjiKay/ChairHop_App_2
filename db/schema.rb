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

ActiveRecord::Schema[7.1].define(version: 2026_04_11_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointment_add_ons", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.string "service_name"
    t.decimal "price", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "service_id"
    t.index ["appointment_id"], name: "index_appointment_add_ons_on_appointment_id"
    t.index ["service_id"], name: "index_appointment_add_ons_on_service_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "time"
    t.text "content"
    t.bigint "customer_id"
    t.bigint "stylist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "salon"
    t.string "selected_service"
    t.vector "embedding", limit: 1536
    t.integer "status", default: 0, null: false
    t.decimal "payment_amount", precision: 10, scale: 2
    t.string "payment_status", default: "pending"
    t.string "payment_id"
    t.string "payment_method"
    t.bigint "location_id"
    t.bigint "availability_block_id"
    t.string "balance_payment_id"
    t.text "cancellation_reason"
    t.string "cancelled_by"
    t.datetime "cancelled_at"
    t.integer "cancelled_by_id"
    t.datetime "end_time"
    t.datetime "completed_at"
    t.string "square_checkout_id"
    t.decimal "balance_collected", precision: 10, scale: 2
    t.text "square_card_id"
    t.datetime "hold_expires_at"
    t.index ["availability_block_id", "time"], name: "index_appointments_on_availability_block_id_and_time"
    t.index ["availability_block_id"], name: "index_appointments_on_availability_block_id"
    t.index ["cancelled_by_id"], name: "index_appointments_on_cancelled_by_id"
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["location_id"], name: "index_appointments_on_location_id"
    t.index ["square_checkout_id"], name: "index_appointments_on_square_checkout_id"
    t.index ["stylist_id"], name: "index_appointments_on_stylist_id"
  end

  create_table "availability_blocks", force: :cascade do |t|
    t.bigint "stylist_id", null: false
    t.bigint "location_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.boolean "available_for_all_services", default: true
    t.text "service_ids", default: [], array: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_time"], name: "index_availability_blocks_on_end_time"
    t.index ["location_id"], name: "index_availability_blocks_on_location_id"
    t.index ["start_time"], name: "index_availability_blocks_on_start_time"
    t.index ["stylist_id", "start_time"], name: "index_availability_blocks_on_stylist_id_and_start_time"
    t.index ["stylist_id"], name: "index_availability_blocks_on_stylist_id"
  end

  create_table "chats", force: :cascade do |t|
    t.string "title"
    t.bigint "customer_id", null: false
    t.bigint "appointment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "model_id"
    t.index ["appointment_id"], name: "index_chats_on_appointment_id"
    t.index ["customer_id"], name: "index_chats_on_customer_id"
  end

  create_table "conversation_messages", force: :cascade do |t|
    t.string "role"
    t.text "content"
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.index ["conversation_id"], name: "index_conversation_messages_on_conversation_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "stylist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_conversations_on_appointment_id", unique: true
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["stylist_id"], name: "index_conversations_on_stylist_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "street_address", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role"
    t.text "content"
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "content"
    t.bigint "appointment_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "stylist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "stylist_response"
    t.datetime "stylist_responded_at"
    t.index ["appointment_id"], name: "index_reviews_on_appointment_id", unique: true
    t.index ["customer_id"], name: "index_reviews_on_customer_id"
    t.index ["stylist_id"], name: "index_reviews_on_stylist_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", null: false
    t.bigint "stylist_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration_minutes"
    t.boolean "is_add_on", default: false
    t.index ["stylist_id", "name"], name: "index_services_on_stylist_id_and_name", unique: true
    t.index ["stylist_id"], name: "index_services_on_stylist_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id"
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "user_square_customers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stylist_id", null: false
    t.text "square_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stylist_id"], name: "index_user_square_customers_on_stylist_id"
    t.index ["user_id", "stylist_id"], name: "index_user_square_customers_on_user_id_and_stylist_id", unique: true
    t.index ["user_id"], name: "index_user_square_customers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "username"
    t.text "about"
    t.integer "role", default: 0, null: false
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.datetime "onboarding_completed_at"
    t.text "square_access_token"
    t.text "square_refresh_token"
    t.string "square_merchant_id"
    t.datetime "square_connected_at"
    t.string "square_location_id"
    t.string "booking_slug"
    t.index ["booking_slug"], name: "index_users_on_booking_slug", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["square_location_id"], name: "index_users_on_square_location_id"
    t.index ["square_merchant_id"], name: "index_users_on_square_merchant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointment_add_ons", "appointments"
  add_foreign_key "appointment_add_ons", "services"
  add_foreign_key "appointments", "availability_blocks"
  add_foreign_key "appointments", "locations"
  add_foreign_key "appointments", "users", column: "cancelled_by_id"
  add_foreign_key "appointments", "users", column: "customer_id"
  add_foreign_key "appointments", "users", column: "stylist_id"
  add_foreign_key "availability_blocks", "locations"
  add_foreign_key "availability_blocks", "users", column: "stylist_id"
  add_foreign_key "chats", "appointments"
  add_foreign_key "chats", "users", column: "customer_id"
  add_foreign_key "conversation_messages", "conversations"
  add_foreign_key "conversations", "appointments"
  add_foreign_key "conversations", "users", column: "customer_id"
  add_foreign_key "conversations", "users", column: "stylist_id"
  add_foreign_key "locations", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "reviews", "appointments"
  add_foreign_key "reviews", "users", column: "customer_id"
  add_foreign_key "reviews", "users", column: "stylist_id"
  add_foreign_key "services", "users", column: "stylist_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "user_square_customers", "users"
  add_foreign_key "user_square_customers", "users", column: "stylist_id"
end
