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

ActiveRecord::Schema.define(version: 2015_10_08_050355) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "playlists", id: :serial, force: :cascade do |t|
    t.integer "for_user_id", null: false
    t.integer "from_user_id"
    t.string "url", null: false
    t.string "name", limit: 100
    t.text "description"
    t.integer "priority", limit: 2, default: 0, null: false
    t.datetime "listened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "liked", default: false, null: false
    t.index ["for_user_id", "priority"], name: "index_playlists_on_for_user_id_and_priority"
    t.index ["for_user_id", "url"], name: "index_playlists_on_for_user_id_and_url", unique: true
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.string "name", limit: 50, null: false
    t.index ["playlist_id", "name"], name: "index_tags_on_playlist_id_and_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 16, null: false
    t.string "email"
    t.string "crypted_password", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "playlists", "users", column: "for_user_id", on_delete: :cascade
  add_foreign_key "playlists", "users", column: "from_user_id", on_delete: :nullify
  add_foreign_key "tags", "playlists", on_delete: :cascade
end
