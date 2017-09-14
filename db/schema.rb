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

ActiveRecord::Schema.define(version: 20130709121200) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "uuid-ossp"

  create_table "locations", force: true do |t|
    t.string   "name",       null: false
    t.string   "sti_type"
    t.string   "ancestry"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ancestry"], :name => "index_locations_on_ancestry"
  end

  create_table "purchases", force: true do |t|
    t.string   "name",             null: false
    t.string   "responsible",      null: false
    t.string   "phone_number"
    t.string   "fax"
    t.string   "email",            null: false
    t.string   "ssn_code"
    t.string   "vat_code"
    t.string   "address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "country"
    t.integer  "location_id"
    t.integer  "accounts_number",  null: false
    t.boolean  "includes_invoice", null: false
    t.datetime "release_date",     null: false
    t.datetime "start_date",       null: false
    t.datetime "expiration_date",  null: false
    t.string   "token",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["location_id"], :name => "fk__purchases_location_id"
    t.foreign_key ["location_id"], "locations", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_purchases_location_id"
  end

  create_table "school_levels", force: true do |t|
    t.string   "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",              null: false
    t.string   "name",               null: false
    t.string   "surname",            null: false
    t.integer  "school_level_id",    null: false
    t.string   "encrypted_password", null: false
    t.boolean  "confirmed",          null: false
    t.boolean  "active",             null: false
    t.integer  "location_id"
    t.string   "confirmation_token"
    t.text     "metadata"
    t.string   "password_token"
    t.integer  "purchase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], :name => "index_users_on_active"
    t.index ["confirmation_token"], :name => "index_users_on_confirmation_token"
    t.index ["confirmed"], :name => "index_users_on_confirmed"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["location_id"], :name => "fk__users_location_id"
    t.index ["password_token"], :name => "index_users_on_password_token"
    t.index ["purchase_id"], :name => "fk__users_purchase_id"
    t.index ["school_level_id"], :name => "fk__users_school_level_id"
    t.foreign_key ["location_id"], "locations", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_location_id"
    t.foreign_key ["purchase_id"], "purchases", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_purchase_id"
    t.foreign_key ["school_level_id"], "school_levels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_school_level_id"
  end

# Could not dump table "bookmarks" because of following StandardError
#   Unknown type 'teaching_object' for column 'bookmarkable_type'

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], :name => "delayed_jobs_priority"
  end

  create_table "documents", force: true do |t|
    t.integer  "user_id",     null: false
    t.string   "title"
    t.text     "description"
    t.string   "attachment",  null: false
    t.text     "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__documents_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_documents_user_id"
  end

  create_table "subjects", force: true do |t|
    t.string   "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lessons", force: true do |t|
    t.uuid     "uuid", :default => { :expr => "uuid_generate_v4()" },                                null: false
    t.integer  "user_id",                             null: false
    t.integer  "school_level_id",                     null: false
    t.integer  "subject_id",                          null: false
    t.string   "title",                               null: false
    t.text     "description",                         null: false
    t.boolean  "is_public",           default: false, null: false
    t.integer  "parent_id"
    t.boolean  "copied_not_modified",                 null: false
    t.string   "token",                               null: false
    t.text     "metadata"
    t.boolean  "notified",            default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["parent_id"], :name => "fk__lessons_parent_id"
    t.index ["school_level_id"], :name => "fk__lessons_school_level_id"
    t.index ["subject_id"], :name => "fk__lessons_subject_id"
    t.index ["user_id"], :name => "fk__lessons_user_id"
    t.foreign_key ["parent_id"], "lessons", ["id"], :on_update => :no_action, :on_delete => :set_null, :name => "fk_lessons_parent_id"
    t.foreign_key ["school_level_id"], "school_levels", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_lessons_school_level_id"
    t.foreign_key ["subject_id"], "subjects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_lessons_subject_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_lessons_user_id"
  end

# Could not dump table "slides" because of following StandardError
#   Unknown type 'slide_type' for column 'kind'

  create_table "documents_slides", force: true do |t|
    t.integer  "document_id", null: false
    t.integer  "slide_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["document_id"], :name => "fk__documents_slides_document_id"
    t.index ["slide_id"], :name => "fk__documents_slides_slide_id"
    t.foreign_key ["document_id"], "documents", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_documents_slides_document_id"
    t.foreign_key ["slide_id"], "slides", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_documents_slides_slide_id"
  end

  create_table "likes", force: true do |t|
    t.integer  "lesson_id",  null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lesson_id"], :name => "fk__likes_lesson_id"
    t.index ["user_id"], :name => "fk__likes_user_id"
    t.foreign_key ["lesson_id"], "lessons", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_likes_lesson_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_likes_user_id"
  end

  create_table "mailing_list_groups", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__mailing_list_groups_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_mailing_list_groups_user_id"
  end

  create_table "mailing_list_addresses", force: true do |t|
    t.integer  "group_id"
    t.string   "heading"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id"], :name => "fk__mailing_list_addresses_group_id"
    t.foreign_key ["group_id"], "mailing_list_groups", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_mailing_list_addresses_group_id"
  end

  create_table "media_elements", force: true do |t|
    t.integer  "user_id",                          null: false
    t.string   "sti_type",                         null: false
    t.string   "media"
    t.string   "title",                            null: false
    t.text     "description",                      null: false
    t.text     "metadata"
    t.boolean  "converted",        default: false, null: false
    t.boolean  "is_public",        default: false, null: false
    t.datetime "publication_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__media_elements_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_media_elements_user_id"
  end

  create_table "media_elements_slides", force: true do |t|
    t.integer  "media_element_id",                 null: false
    t.integer  "slide_id",                         null: false
    t.integer  "position",                         null: false
    t.text     "caption"
    t.boolean  "inscribed",        default: false, null: false
    t.integer  "alignment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["media_element_id"], :name => "fk__media_elements_slides_media_element_id"
    t.index ["slide_id"], :name => "fk__media_elements_slides_slide_id"
    t.foreign_key ["media_element_id"], "media_elements", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_media_elements_slides_media_element_id"
    t.foreign_key ["slide_id"], "slides", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_media_elements_slides_slide_id"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id",                    null: false
    t.text     "message",                    null: false
    t.string   "title",                      null: false
    t.text     "basement"
    t.boolean  "seen",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__notifications_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_notifications_user_id"
  end

# Could not dump table "reports" because of following StandardError
#   Unknown type 'teaching_object' for column 'reportable_type'

  create_table "tags", force: true do |t|
    t.string   "word",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["word"], :name => "index_tags_on_word", :unique => true
  end

# Could not dump table "taggings" because of following StandardError
#   Unknown type 'teaching_object' for column 'taggable_type'

  create_table "users_subjects", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "subject_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["subject_id"], :name => "fk__users_subjects_subject_id"
    t.index ["user_id"], :name => "fk__users_subjects_user_id"
    t.foreign_key ["subject_id"], "subjects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_subjects_subject_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_subjects_user_id"
  end

  create_table "virtual_classroom_lessons", force: true do |t|
    t.integer  "lesson_id",  null: false
    t.integer  "user_id",    null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["lesson_id"], :name => "fk__virtual_classroom_lessons_lesson_id"
    t.index ["user_id"], :name => "fk__virtual_classroom_lessons_user_id"
    t.foreign_key ["lesson_id"], "lessons", ["id"], :on_update => :no_action, :on_delete => :cascade, :name => "fk_virtual_classroom_lessons_lesson_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_virtual_classroom_lessons_user_id"
  end

end
