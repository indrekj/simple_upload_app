class Initial < ActiveRecord::Migration
  def self.up
    create_table "assessments", :force => true do |t|
      t.string   "title"
      t.string   "author",                     :default => "itimees"
      t.integer  "year"
      t.text     "body"
      t.string   "content_type"
      t.string   "creator_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "source",       :limit => 20, :default => "unknown"
      t.integer  "category_id"
      t.boolean  "confirmed",                  :default => false
    end

    create_table "categories", :force => true do |t|
      t.string   "name",              :limit => 50
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
end
