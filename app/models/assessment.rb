require "hpricot"
require "paperclip_processors/assessment_processor"

class Assessment < ActiveRecord::Base
  module Sources
    WEBCT = "webct"
    MOODLE = "moodle"
    UNKNOWN = "unknown"
  end
 
  has_attached_file :test, :processors => [:assessment_processor], :styles => {:clean => {}}

  # Callbacks
  before_validation(:on => :create) do
    if self.year.blank? || self.year > Time.now.year || self.year < 2000 
      self.year = Time.now.year
    end
  end
  before_validation do
    self.assign_category unless self.category_name.blank?
  end

  before_update Proc.new {|a| a.confirmed = true}

  # Associations
  belongs_to :category, :counter_cache => true

  # Validations
  validates :title, :presence => true, :on => :update
  validates :category_name, :presence => true, :if => Proc.new {|a| a[:category].blank?}, :on => :update
  validates :attempt_id, :uniqueness => {:scope => :source}, :allow_blank => true
  
  validates_attachment_presence :test
  validates_attachment_content_type :test, :content_type => [/application/, /plain/, /htm/]
  validates_attachment_size :test, :less_than => 300.kilobytes

  scope :confirmed, :conditions => {:confirmed => true}
  scope :unconfirmed, :conditions => {:confirmed => false}

  def body
    self.test ? File.read(self.test.path(:clean)) : ""
  end

  def title=(t)
    self[:title] = t.to_s.strip
  end

  attr_writer :category_name
  def category_name
    @category_name || self.category && self.category.name
  end

  protected

  def assign_category
    cat = Category.first(:conditions => ["LOWER(name) = ?", self.category_name.downcase])
    cat ||= Category.create(:name => self.category_name)

    self[:category_id] = cat.id
  end
end
