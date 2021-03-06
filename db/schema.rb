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

ActiveRecord::Schema.define(version: 20170527124843) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "casts", force: :cascade do |t|
    t.string   "character"
    t.integer  "show_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crews", force: :cascade do |t|
    t.string   "job"
    t.string   "job_group"
    t.integer  "show_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",         default: 0, null: false
    t.integer  "attempts",         default: 0, null: false
    t.text     "handler",                      null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress_stage"
    t.integer  "progress_current", default: 0
    t.integer  "progress_max",     default: 0
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "donations", force: :cascade do |t|
    t.string   "ex_id"
    t.string   "name"
    t.string   "amount"
    t.string   "comment"
    t.datetime "donation_date"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.decimal  "amount_payed",   precision: 12, scale: 2, default: "0.0"
    t.decimal  "amount_cash",    precision: 12, scale: 2, default: "0.0"
    t.string   "payment_system"
    t.index ["ex_id"], name: "index_donations_on_ex_id", using: :btree
  end

  create_table "episodes", force: :cascade do |t|
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
    t.text     "screenshot_meta"
    t.json     "trakt_data"
    t.json     "tmdb_data"
    t.json     "tmdb_images"
    t.json     "fanart_images"
  end

  create_table "genres", force: :cascade do |t|
    t.string   "name_ru"
    t.string   "name_en"
    t.string   "slug_ru"
    t.string   "slug_en"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres_shows", id: false, force: :cascade do |t|
    t.integer "show_id"
    t.integer "genre_id"
    t.index ["genre_id"], name: "index_genres_shows_on_genre_id", using: :btree
    t.index ["show_id"], name: "index_genres_shows_on_show_id", using: :btree
  end

  create_table "imdb_ratings", force: :cascade do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rating_id"], name: "index_imdb_ratings_on_rating_id", using: :btree
  end

  create_table "kp_ratings", force: :cascade do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rating_id"], name: "index_kp_ratings_on_rating_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "slug_ru"
    t.string   "slug_en"
    t.string   "name_ru"
    t.string   "name_en"
    t.text     "biography_ru"
    t.text     "biography_en"
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
    t.text     "headshot_meta"
  end

  create_table "ratings", force: :cascade do |t|
    t.string   "rated_type"
    t.integer  "rated_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rated_type", "rated_id"], name: "index_ratings_on_rated_type_and_rated_id", using: :btree
  end

  create_table "seasons", force: :cascade do |t|
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
    t.text     "poster_meta"
    t.text     "thumb_meta"
    t.json     "trakt_data"
    t.json     "tmdb_data"
    t.json     "tmdb_images"
    t.json     "fanart_images"
  end

  create_table "seos", force: :cascade do |t|
    t.string   "title",       limit: 75
    t.string   "description", limit: 255
    t.string   "robots"
    t.string   "meta_type"
    t.integer  "meta_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["meta_type", "meta_id"], name: "index_seos_on_meta_type_and_meta_id", using: :btree
  end

  create_table "shows", force: :cascade do |t|
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
    t.text     "poster_meta"
    t.text     "poster_ru_meta"
    t.text     "fanart_meta"
    t.text     "logo_meta"
    t.text     "clearart_meta"
    t.text     "banner_meta"
    t.text     "thumb_meta"
    t.json     "trakt_data"
    t.json     "tmdb_data"
    t.json     "tmdb_images"
    t.json     "fanart_images"
    t.index ["network"], name: "index_shows_on_network", using: :btree
    t.index ["year"], name: "index_shows_on_year", using: :btree
  end

  create_table "translations", force: :cascade do |t|
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
    t.integer  "expires",        default: 0
    t.string   "subtitles",      default: ""
  end

  create_table "translators", force: :cascade do |t|
    t.string   "name"
    t.integer  "ex_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "provider"
    t.string   "uid"
    t.text     "avatar_meta"
    t.string   "name"
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "location"
    t.json     "urls"
    t.integer  "sex"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "zb_ratings", force: :cascade do |t|
    t.integer  "rating_id"
    t.decimal  "value",      precision: 10, scale: 3
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["rating_id"], name: "index_zb_ratings_on_rating_id", using: :btree
  end

end
