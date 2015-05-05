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

ActiveRecord::Schema.define(version: 20150325105893) do

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id",   limit: 4
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id",       limit: 4
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters",     limit: 65535
    t.integer  "recipient_id",   limit: 4
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file",           limit: 255
    t.string   "title",          limit: 255
    t.text     "description",    limit: 65535
    t.integer  "parent_id",      limit: 4
    t.string   "parent_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type",   limit: 255
    t.integer  "file_size",      limit: 4
    t.integer  "author_user_id", limit: 4
  end

  add_index "attachments", ["author_user_id"], name: "attachments_author_user_id_fk", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "bookmarkable_id",   limit: 4
    t.string   "bookmarkable_type", limit: 255
    t.integer  "user_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["user_id"], name: "bookmarks_user_id_fk", using: :btree

  create_table "dag_links", force: :cascade do |t|
    t.integer  "ancestor_id",     limit: 4
    t.string   "ancestor_type",   limit: 255
    t.integer  "descendant_id",   limit: 4
    t.string   "descendant_type", limit: 255
    t.boolean  "direct",          limit: 1
    t.integer  "count",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_to"
    t.datetime "valid_from"
  end

  add_index "dag_links", ["ancestor_id", "ancestor_type", "direct"], name: "dag_ancestor", using: :btree
  add_index "dag_links", ["descendant_id", "descendant_type"], name: "dag_descendant", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.text     "description",               limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",                  limit: 255
    t.boolean  "publish_on_global_website", limit: 1
    t.boolean  "publish_on_local_website",  limit: 1
  end

  create_table "flags", force: :cascade do |t|
    t.string   "key",           limit: 255
    t.integer  "flagable_id",   limit: 4
    t.string   "flagable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["flagable_id", "flagable_type", "key"], name: "flagable_key", using: :btree
  add_index "flags", ["flagable_id", "flagable_type"], name: "flagable", using: :btree
  add_index "flags", ["key"], name: "key", using: :btree

  create_table "geo_locations", force: :cascade do |t|
    t.string   "address",      limit: 255
    t.float    "latitude",     limit: 24
    t.float    "longitude",    limit: 24
    t.string   "country",      limit: 255
    t.string   "country_code", limit: 255
    t.string   "city",         limit: 255
    t.string   "postal_code",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "queried_at"
  end

  add_index "geo_locations", ["address"], name: "index_geo_locations_on_address", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",          limit: 255
    t.string   "extensive_name", limit: 255
    t.string   "internal_token", limit: 255
    t.text     "body",           limit: 65535
    t.string   "type",           limit: 255
  end

  create_table "last_seen_activities", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.string   "description",         limit: 255
    t.integer  "link_to_object_id",   limit: 4
    t.string   "link_to_object_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "last_seen_activities", ["user_id"], name: "last_seen_activities_user_id_fk", using: :btree

  create_table "nav_nodes", force: :cascade do |t|
    t.string   "url_component",   limit: 255
    t.string   "breadcrumb_item", limit: 255
    t.string   "menu_item",       limit: 255
    t.boolean  "slim_breadcrumb", limit: 1
    t.boolean  "slim_url",        limit: 1
    t.boolean  "slim_menu",       limit: 1
    t.boolean  "hidden_menu",     limit: 1
    t.integer  "navable_id",      limit: 4
    t.string   "navable_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nav_nodes", ["navable_id", "navable_type"], name: "navable_type", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "content",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "redirect_to",    limit: 255
    t.integer  "author_user_id", limit: 4
    t.string   "type",           limit: 255
  end

  add_index "pages", ["author_user_id"], name: "pages_author_user_id_fk", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "subject",         limit: 255
    t.text     "text",            limit: 65535
    t.integer  "group_id",        limit: 4
    t.integer  "author_user_id",  limit: 4
    t.string   "external_author", limit: 255
    t.datetime "sent_at"
    t.boolean  "sticky",          limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "entire_message",  limit: 65535
  end

  add_index "posts", ["author_user_id"], name: "posts_author_user_id_fk", using: :btree
  add_index "posts", ["group_id"], name: "posts_group_id_fk", using: :btree

  create_table "profile_fields", force: :cascade do |t|
    t.integer  "profileable_id",   limit: 4
    t.string   "label",            limit: 255
    t.string   "type",             limit: 255
    t.text     "value",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profileable_type", limit: 255
    t.integer  "parent_id",        limit: 4
  end

  add_index "profile_fields", ["parent_id"], name: "profile_fields_parent_id_fk", using: :btree
  add_index "profile_fields", ["profileable_id", "profileable_type", "type"], name: "profileable_type", using: :btree
  add_index "profile_fields", ["profileable_id", "profileable_type"], name: "profileable", using: :btree
  add_index "profile_fields", ["type"], name: "type", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user1_id",   limit: 4
    t.integer  "user2_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["user1_id"], name: "relationships_user1_id_fk", using: :btree
  add_index "relationships", ["user2_id"], name: "relationships_user2_id_fk", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id",   limit: 4
    t.string   "thing_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "status_group_membership_infos", force: :cascade do |t|
    t.integer  "membership_id",           limit: 4
    t.integer  "promoted_by_workflow_id", limit: 4
    t.integer  "promoted_on_event_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                limit: 4
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "auth_token",             limit: 255
  end

  add_index "user_accounts", ["reset_password_token"], name: "index_user_accounts_on_reset_password_token", unique: true, using: :btree
  add_index "user_accounts", ["user_id"], name: "user_accounts_user_id_fk", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "alias",             limit: 255
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "female",            limit: 1
    t.string   "accepted_terms",    limit: 255
    t.datetime "accepted_terms_at"
    t.boolean  "incognito",         limit: 1
    t.string   "avatar_id",         limit: 255
  end

  create_table "workflow_kit_parameters", force: :cascade do |t|
    t.string   "key",                limit: 255
    t.string   "value",              limit: 255
    t.integer  "parameterable_id",   limit: 4
    t.string   "parameterable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_kit_steps", force: :cascade do |t|
    t.integer  "sequence_index", limit: 4
    t.integer  "workflow_id",    limit: 4
    t.string   "brick_name",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_kit_steps", ["workflow_id"], name: "workflow_kit_steps_workflow_id_fk", using: :btree

  create_table "workflow_kit_workflows", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflows", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "attachments", "users", column: "author_user_id", name: "attachments_author_user_id_fk"
  add_foreign_key "bookmarks", "users", name: "bookmarks_user_id_fk"
  add_foreign_key "last_seen_activities", "users", name: "last_seen_activities_user_id_fk"
  add_foreign_key "pages", "users", column: "author_user_id", name: "pages_author_user_id_fk"
  add_foreign_key "posts", "groups", name: "posts_group_id_fk"
  add_foreign_key "posts", "users", column: "author_user_id", name: "posts_author_user_id_fk"
  add_foreign_key "profile_fields", "profile_fields", column: "parent_id", name: "profile_fields_parent_id_fk"
  add_foreign_key "relationships", "users", column: "user1_id", name: "relationships_user1_id_fk"
  add_foreign_key "relationships", "users", column: "user2_id", name: "relationships_user2_id_fk"
  add_foreign_key "user_accounts", "users", name: "user_accounts_user_id_fk"
  add_foreign_key "workflow_kit_steps", "workflow_kit_workflows", column: "workflow_id", name: "workflow_kit_steps_workflow_id_fk"
end
