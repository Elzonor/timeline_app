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

ActiveRecord::Schema[8.0].define(version: 2025_04_13_135650) do
  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "timeline_id"
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.string "color"
    t.string "event_type", default: "open", null: false
    t.string "event_duration", default: "1-day", null: false
    t.index ["end_date"], name: "index_events_on_end_date"
    t.index ["event_duration"], name: "index_events_on_event_duration"
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["start_date"], name: "index_events_on_start_date"
    t.index ["timeline_id"], name: "index_events_on_timeline_id"
  end

  create_table "timeline_preferences", force: :cascade do |t|
    t.integer "timeline_id", null: false
    t.string "view_type", default: "weeks", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timeline_id"], name: "index_timeline_preferences_on_timeline_id", unique: true
  end

  create_table "timelines", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "event_id"
    t.index "LOWER(name)", name: "index_timelines_on_name_case_insensitive", unique: true
  end

  add_foreign_key "timeline_preferences", "timelines"
end
