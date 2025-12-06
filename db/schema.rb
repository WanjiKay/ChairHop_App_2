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

ActiveRecord::Schema[7.1].define(version: 2025_12_03_001119) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["appointment_id"], name: "index_appointment_add_ons_on_appointment_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "time"
    t.string "location"
    t.boolean "booked"
    t.text "content"
    t.bigint "customer_id"
    t.bigint "stylist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "services"
    t.string "salon"
    t.string "selected_service"
    t.jsonb "embedding", default: [], null: false
    t.integer "status", default: 0, null: false
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["stylist_id"], name: "index_appointments_on_stylist_id"
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
    t.index ["conversation_id"], name: "index_conversation_messages_on_conversation_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "stylist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_conversations_on_appointment_id"
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["stylist_id"], name: "index_conversations_on_stylist_id"
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
    t.index ["appointment_id"], name: "index_reviews_on_appointment_id"
    t.index ["customer_id"], name: "index_reviews_on_customer_id"
    t.index ["stylist_id"], name: "index_reviews_on_stylist_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
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
    t.string "location"
    t.text "about"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointment_add_ons", "appointments"
  add_foreign_key "appointments", "users", column: "customer_id"
  add_foreign_key "appointments", "users", column: "stylist_id"
  add_foreign_key "chats", "appointments"
  add_foreign_key "chats", "users", column: "customer_id"
  add_foreign_key "conversation_messages", "conversations"
  add_foreign_key "conversations", "appointments"
  add_foreign_key "conversations", "users", column: "customer_id"
  add_foreign_key "conversations", "users", column: "stylist_id"
  add_foreign_key "messages", "chats"
  add_foreign_key "reviews", "appointments"
  add_foreign_key "reviews", "users", column: "customer_id"
  add_foreign_key "reviews", "users", column: "stylist_id"
end
