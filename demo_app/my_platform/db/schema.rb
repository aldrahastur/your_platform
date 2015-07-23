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

ActiveRecord::Schema.define(version: 20150707223927) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file"
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "author_user_id"
  end

  create_table "badges_sashes", force: :cascade do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", default: false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], name: "index_badges_sashes_on_badge_id_and_sash_id", using: :btree
  add_index "badges_sashes", ["badge_id"], name: "index_badges_sashes_on_badge_id", using: :btree
  add_index "badges_sashes", ["sash_id"], name: "index_badges_sashes_on_sash_id", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "bookmarkable_id"
    t.string   "bookmarkable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "text"
    t.integer  "author_user_id"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "dag_links", force: :cascade do |t|
    t.integer  "ancestor_id"
    t.string   "ancestor_type"
    t.integer  "descendant_id"
    t.string   "descendant_type"
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_to"
    t.datetime "valid_from"
  end

  add_index "dag_links", ["ancestor_id", "ancestor_type", "direct"], name: "dag_ancestor", using: :btree
  add_index "dag_links", ["descendant_id", "descendant_type"], name: "dag_descendant", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.boolean  "publish_on_global_website"
    t.boolean  "publish_on_local_website"
  end

  create_table "flags", force: :cascade do |t|
    t.string   "key"
    t.integer  "flagable_id"
    t.string   "flagable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["flagable_id", "flagable_type", "key"], name: "flagable_key", using: :btree
  add_index "flags", ["flagable_id", "flagable_type"], name: "flagable", using: :btree
  add_index "flags", ["key"], name: "key", using: :btree

  create_table "geo_locations", force: :cascade do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country"
    t.string   "country_code"
    t.string   "city"
    t.string   "postal_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "queried_at"
    t.string   "street"
    t.string   "state"
  end

  add_index "geo_locations", ["address"], name: "index_geo_locations_on_address", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "extensive_name"
    t.string   "internal_token"
    t.text     "body"
    t.string   "type"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "reference_id"
    t.string   "reference_type"
    t.datetime "resolved_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "responsible_admin_id"
  end

  create_table "last_seen_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "description"
    t.integer  "link_to_object_id"
    t.string   "link_to_object_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mentions", force: :cascade do |t|
    t.integer  "who_user_id"
    t.integer  "whom_user_id"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "mentions", ["whom_user_id"], name: "index_mentions_on_whom_user_id", using: :btree

  create_table "merit_actions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",    default: false
    t.string   "target_model"
    t.integer  "target_id"
    t.text     "target_data"
    t.boolean  "processed",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merit_activity_logs", force: :cascade do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", force: :cascade do |t|
    t.integer  "score_id"
    t.integer  "num_points", default: 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", force: :cascade do |t|
    t.integer "sash_id"
    t.string  "category", default: "default"
  end

  create_table "nav_nodes", force: :cascade do |t|
    t.string   "url_component"
    t.string   "breadcrumb_item"
    t.string   "menu_item"
    t.boolean  "slim_breadcrumb"
    t.boolean  "slim_url"
    t.boolean  "slim_menu"
    t.boolean  "hidden_menu"
    t.integer  "navable_id"
    t.string   "navable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nav_nodes", ["navable_id", "navable_type"], name: "navable_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "author_id"
    t.string   "reference_url"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.string   "message"
    t.text     "text"
    t.datetime "sent_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "read_at"
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "redirect_to"
    t.integer  "author_user_id"
    t.string   "type"
  end

  create_table "posts", force: :cascade do |t|
    t.string   "subject"
    t.text     "text"
    t.integer  "group_id"
    t.integer  "author_user_id"
    t.string   "external_author"
    t.datetime "sent_at"
    t.boolean  "sticky"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "entire_message"
    t.string   "message_id"
    t.string   "content_type"
  end

  create_table "profile_fields", force: :cascade do |t|
    t.integer  "profileable_id"
    t.string   "label"
    t.string   "type"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profileable_type"
    t.integer  "parent_id"
  end

  add_index "profile_fields", ["profileable_id", "profileable_type", "type"], name: "profileable_type", using: :btree
  add_index "profile_fields", ["profileable_id", "profileable_type"], name: "profileable", using: :btree
  add_index "profile_fields", ["type"], name: "type", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "name"
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sashes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",        null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "status_group_membership_infos", force: :cascade do |t|
    t.integer  "membership_id"
    t.integer  "promoted_by_workflow_id"
    t.integer  "promoted_on_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.string   "encrypted_password",     default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "auth_token"
  end

  add_index "user_accounts", ["reset_password_token"], name: "index_user_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "alias"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "female"
    t.string   "accepted_terms"
    t.datetime "accepted_terms_at"
    t.boolean  "incognito"
    t.string   "avatar_id"
    t.string   "notification_policy"
    t.string   "locale"
    t.integer  "sash_id"
    t.integer  "level",               default: 0
  end

  create_table "workflow_kit_parameters", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "parameterable_id"
    t.string   "parameterable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_kit_steps", force: :cascade do |t|
    t.integer  "sequence_index"
    t.integer  "workflow_id"
    t.string   "brick_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_kit_workflows", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflows", force: :cascade do |t|
    t.string   "name"
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
