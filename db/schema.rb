# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 5) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "public_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "authorizations", force: :cascade do |t|
    t.integer  "role",       default: 0, null: false
    t.integer  "user_id",                null: false
    t.integer  "website_id",             null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree
  add_index "authorizations", ["website_id"], name: "index_authorizations_on_website_id", using: :btree

  create_table "deployments", force: :cascade do |t|
    t.integer  "website_id",       null: false
    t.text     "branch_name",      null: false
    t.text     "host_prefix",      null: false
    t.text     "response_message"
    t.integer  "response_status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "deployments", ["website_id"], name: "index_deployments_on_website_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "email",                                    null: false
    t.text     "password_digest"
    t.text     "name"
    t.text     "email_confirmation_token"
    t.text     "password_reset_token"
    t.text     "session_token"
    t.boolean  "confirmed",                default: false, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "users", ["email_confirmation_token"], name: "index_users_on_email_confirmation_token", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true, using: :btree
  add_index "users", ["session_token"], name: "index_users_on_session_token", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.text     "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "authorizations", "users"
  add_foreign_key "authorizations", "websites"
  add_foreign_key "deployments", "websites"
end
