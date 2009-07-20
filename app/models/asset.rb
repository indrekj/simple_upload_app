class Asset < ActiveRecord::Base
  validates_presence_of :title, :message => 'Tiitel peab olema lisatud'
  validates_presence_of :category, :message => 'Tüüp peab olema lisatud'
  validates_numericality_of :year, :greater_than => 2008, :less_than => 2020, :message => 'Aasta paeb olema neljakohaline ning reaalne'

  before_save :check_year

  def title=(t)
    self[:title] = t.to_s.strip
  end

  def category=(c)
    self[:category] = c.to_s.strip
  end

  def year
    self[:year] || Time.now.year
  end

  def file
    @file
  end

  def file=(f)
    @file = f.clone
    write_attribute(:body, f.read)
    write_attribute(:content_type, f.content_type)
  end

  def to_json(options = {:except => 'body'})
    super(options)
  end

  protected

  def check_year
    unless self[:year] < 2030 && self[:year] > 2000
      self[:year] = Time.now.year
    end
  end

  def validate
    puts "asdfasd"
    puts file.inspect
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
