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

ActiveRecord::Schema.define(version: 20140321030104) do

  create_table "comments", force: true do |t|
    t.string   "commentable_type",                 null: false
    t.integer  "commentable_id",                   null: false
    t.integer  "comments_count",   default: 0,     null: false
    t.string   "source",                           null: false
    t.string   "source_id",                        null: false
    t.integer  "user_id",                          null: false
    t.datetime "created",                          null: false
    t.integer  "post_id",                          null: false
    t.text     "body"
    t.boolean  "is_deleted",       default: false, null: false
    t.text     "original_body",                    null: false
    t.datetime "modified"
    t.integer  "modified_by"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
  add_index "comments", ["modified_by"], name: "index_comments_on_modified_by", using: :btree
  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "posts", force: true do |t|
    t.string   "subject",                        null: false
    t.text     "body"
    t.integer  "user_id",                        null: false
    t.datetime "created",                        null: false
    t.string   "tags"
    t.string   "source"
    t.string   "source_id"
    t.boolean  "is_deleted",     default: false, null: false
    t.integer  "comments_count", default: 0,     null: false
    t.string   "starred_by"
    t.datetime "modified"
    t.integer  "modified_by"
    t.integer  "stars_count",    default: 0,     null: false
  end

  add_index "posts", ["modified_by"], name: "index_posts_on_modified_by", using: :btree
  add_index "posts", ["source", "source_id"], name: "index_posts_on_source_and_source_id", unique: true, using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "stars", force: true do |t|
    t.integer  "user_id",       null: false
    t.string   "starable_type", null: false
    t.integer  "starable_id",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "stars", ["starable_type", "starable_id"], name: "index_stars_on_starable_type_and_starable_id", using: :btree
  add_index "stars", ["user_id"], name: "index_stars_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                                                      null: false
    t.string   "email",                                                     null: false
    t.datetime "created",                                                   null: false
    t.string   "other_emails"
    t.string   "avartar",      default: "http://www.gravatar.com/avatar/a", null: false
    t.text     "notification"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["other_emails"], name: "index_users_on_other_emails", using: :btree

end
