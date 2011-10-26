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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111026170519) do

  create_table "assessments", :force => true do |t|
    t.string   "title"
    t.string   "author",                          :default => "itimees"
    t.integer  "year"
    t.string   "test_file_name"
    t.string   "test_content_type"
    t.integer  "test_file_size"
    t.datetime "test_updated_at"
    t.string   "creator_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source",            :limit => 20, :default => "unknown"
    t.integer  "category_id"
    t.boolean  "confirmed",                       :default => false
    t.integer  "attempt_id"
  end

  create_table "categories", :force => true do |t|
    t.string   "name",              :limit => 80
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessments_count",               :default => 0
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.string   "description"
    t.string   "creator_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
