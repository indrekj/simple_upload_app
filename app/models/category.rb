class Category < ActiveRecord::Base
  has_many :assets

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
