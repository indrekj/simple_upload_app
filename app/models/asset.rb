require "hpricot"

class Asset < ActiveRecord::Base
  module Sources
    WEBCT = "webct"
    MOODLE = "moodle"
    UNKNOWN = "unknown"
  end
  
  attr_accessor :category_name

  before_validation_on_create :determine_source!
  before_validation_on_create :determine_type_and_title!

  # can't use before_validation because it happens before the before_validation_on_create
  before_validation_on_create :assign_category, :if => Proc.new {|a| !a.category_name.blank?}
  before_validation_on_update :assign_category, :if => Proc.new {|a| !a.category_name.blank?}

  before_create :remove_delicate_info!
  before_save :check_year
  before_save Proc.new {|a| a.file.delete if a.file}
  before_update Proc.new {|a| a.confirmed = true}

  belongs_to :category, :counter_cache => true

  validates_presence_of :title, :on => :update
  validates_presence_of :category_name, :if => Proc.new {|a| a[:category].blank?}, :on => :update
  validates_numericality_of :year, :greater_than => 2007, :less_than => 2020, :on => :update

  default_value_for :year, Time.now.year

  named_scope :confirmed, :conditions => {:confirmed => true}
  named_scope :unconfirmed, :conditions => {:confirmed => false}

  def title=(t)
    self[:title] = t.to_s.strip
  end

  def category=(c)
    self[:category] = c.to_s.strip
  end

  def file
    @file
  end

  def file=(f)
    @file = f
    write_attribute(:body, f.read)
    write_attribute(:content_type, f.content_type)
  end

  def determine_source!
    self.source = 
      case body
      when /moodle/i then Sources::MOODLE
      when /webct/i then Sources::WEBCT
      else
        Sources::UNKNOWN
      end
  end

  def determine_type_and_title!
    case self.source
    when Sources::MOODLE
      doc = Hpricot.parse(self.body)
      self.title = doc.search("tr/td/div[3]/div/ul/li[4]/a").innerHTML.strip
      self.category_name = doc.search("tr/td/div/h1").innerHTML.strip
    when Sources::WEBCT
      doc = Hpricot.parse(self.body)
      self.title = doc.search(".controlset/table/tr[1]/td[2]").innerHTML.strip
    end

    self.title = "" if self.title.to_s.downcase == "test"
  end

  def remove_delicate_info!
    case self.source
    when Sources::MOODLE
      # No need for header (including user real name)
      body.gsub!(/<div id="header" .*?(<div id="content")/m, '\1')

      # No need for submit forms
      body.gsub!(/<form.*?<\/form>/m, "")

      # Hacking attempts? No need for these either.
      body.gsub!(/sesskey=.{10}/, "")
    end

    # AR doesn't like to touch when using gsub!. << :)
    self.body_will_change!
  end

  def to_json(options = {})
    options[:only] = [:id, :title, :category_name, :author, :year]
    super(options)
  end

  protected

  def assign_category
    cat = Category.first(:conditions => ["LOWER(name) = ?", self.category_name.downcase])
    cat ||= Category.create(:name => self.category_name)

    self[:category_id] = cat.id
  end

  def check_year
    unless self[:year] < 2030 && self[:year] > 2000
      self[:year] = Time.now.year
    end
  end

  def validate
    return unless new_record?
    if file.blank?
      errors.add_to_base "Fail peab olema lisatud"
    else
      if !['.html', '.htm', '.txt'].include?(File.extname(file.original_filename))
        errors.add_to_base "Html ja txt failid ainult"
      elsif file.size > 200 * 1024
        errors.add_to_base "Faili suurus peab olema alla 200KB"
      end
    end
  end
end
