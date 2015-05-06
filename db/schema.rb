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

ActiveRecord::Schema.define(version: 20150505165409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "casts", force: true do |t|
    t.string   "character"
    t.integer  "show_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crews", force: true do |t|
    t.string   "job"
    t.string   "job_group"
    t.integer  "show_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "episodes", force: true do |t|
    t.string   "slug_ru"
    t.string   "slug_en"
    t.string   "title_ru"
    t.string   "title_en"
    t.text     "description_ru"
    t.text     "description_en"
    t.string   "abs_name"
    t.integer  "number"
    t.integer  "number_abs"
    t.json     "ids"
    t.datetime "first_aired"
    t.datetime "air_date"
    t.integer  "show_id"
    t.integer  "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "screenshot_file_name"
    t.string   "screenshot_content_type"
    t.integer  "screenshot_file_size"
    t.datetime "screenshot_updated_at"
  end

  create_table "genres", force: true do |t|
    t.string   "name_ru"
    t.string   "name_en"
    t.string   "slug_ru"
    t.string   "slug_en"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres_shows", id: false, force: true do |t|
    t.integer "show_id"
    t.integer "genre_id"
  end

  add_index "genres_shows", ["genre_id"], name: "index_genres_shows_on_genre_id", using: :btree
  add_index "genres_shows", ["show_id"], name: "index_genres_shows_on_show_id", using: :btree

  create_table "imdb_ratings", force: true do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imdb_ratings", ["rating_id"], name: "index_imdb_ratings_on_rating_id", using: :btree

  create_table "kp_ratings", force: true do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kp_ratings", ["rating_id"], name: "index_kp_ratings_on_rating_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "slug_ru"
    t.string   "slug_en"
    t.string   "name_ru"
    t.string   "biography_ru"
    t.string   "biography_en"
    t.date     "birthday"
    t.date     "death"
    t.string   "birthplace"
    t.integer  "growth"
    t.json     "ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "headshot_file_name"
    t.string   "headshot_content_type"
    t.integer  "headshot_file_size"
    t.datetime "headshot_updated_at"
  end

  create_table "ratings", force: true do |t|
    t.integer  "rated_id"
    t.string   "rated_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["rated_id", "rated_type"], name: "index_ratings_on_rated_id_and_rated_type", using: :btree

  create_table "seasons", force: true do |t|
    t.string   "slug_ru"
    t.string   "slug_en"
    t.string   "title_ru"
    t.string   "title_en"
    t.text     "description_ru"
    t.text     "description_en"
    t.datetime "first_aired"
    t.integer  "number"
    t.json     "ids"
    t.integer  "episode_count"
    t.integer  "aired_episodes"
    t.integer  "show_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.string   "thumb_file_name"
    t.string   "thumb_content_type"
    t.integer  "thumb_file_size"
    t.datetime "thumb_updated_at"
  end

  create_table "shows", force: true do |t|
    t.string   "slug_ru"
    t.string   "slug_en"
    t.string   "title_ru"
    t.string   "title_en"
    t.text     "description_ru"
    t.text     "description_en"
    t.string   "slogan_ru"
    t.string   "slogan_en"
    t.integer  "year"
    t.datetime "first_aired"
    t.datetime "updated"
    t.json     "ids"
    t.json     "airs"
    t.integer  "runtime"
    t.string   "certification"
    t.string   "network"
    t.string   "country"
    t.string   "homepage"
    t.string   "status"
    t.integer  "aired_episodes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fanart_file_name"
    t.string   "fanart_content_type"
    t.integer  "fanart_file_size"
    t.datetime "fanart_updated_at"
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "clearart_file_name"
    t.string   "clearart_content_type"
    t.integer  "clearart_file_size"
    t.datetime "clearart_updated_at"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.string   "thumb_file_name"
    t.string   "thumb_content_type"
    t.integer  "thumb_file_size"
    t.datetime "thumb_updated_at"
    t.string   "poster_ru_file_name"
    t.string   "poster_ru_content_type"
    t.integer  "poster_ru_file_size"
    t.datetime "poster_ru_updated_at"
  end

  create_table "translations", force: true do |t|
    t.string   "translator"
    t.string   "moonwalk_token"
    t.string   "f4m"
    t.string   "m3u8"
    t.string   "local"
    t.datetime "added_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "episode_id"
    t.integer  "translator_id"
  end

  create_table "translators", force: true do |t|
    t.string   "name"
    t.integer  "ex_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zb_ratings", force: true do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zb_ratings", ["rating_id"], name: "index_zb_ratings_on_rating_id", using: :btree

end
