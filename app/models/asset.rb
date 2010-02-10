class Asset < ActiveRecord::Base
  module Sources
    WEBCT = 'webct'
    MOODLE = 'moodle'
    UNKNOWN = 'unknown'
  end

  validates_presence_of :title, :message => 'Tiitel peab olema lisatud'
  validates_presence_of :category, :message => 'Tüüp peab olema lisatud'
  validates_numericality_of :year, :greater_than => 2007, :less_than => 2020, :message => 'Aasta paeb olema neljakohaline ning reaalne'

  before_validation_on_create :determine_source!
  before_create :remove_delicate_info!
  before_save :check_year
  before_save Proc.new {|a| a.file.delete if a.file}

  default_value_for :year, Time.now.year

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

  def to_json(options = {:except => 'body'})
    super(options)
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

  protected

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
