class Asset < ActiveRecord::Base
  validates_presence_of :title, :message => 'Tiitel peab olema lisatud'
  validates_presence_of :category, :message => 'Tüüp peab olema lisatud'
  validates_length_of :year, :is => 4, :message => 'Aasta peab olema neljakohaline number'

  attr_accessor :filename, :tempfile, :filesize

  before_create :upload_file
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

  protected

  def check_year
    unless self[:year] < 2030 && self[:year] > 2000
      self[:year] = Time.now.year
    end
  end

  def upload_file
    unless tempfile.blank?
      self.body = File.read(tempfile.path)
    end
  end

  def validate
    if tempfile.blank? || !File.exists?(tempfile.path)
      errors.add_to_base "Fail peab olema lisatud"
    elsif !['.html', '.htm', '.txt'].include?(File.extname(filename))
      errors.add_to_base "Html ja txt failid ainult"
    elsif filesize > 200 * 1024
      errors.add_to_base "Faili suurus peab olema alla 200KB"
    end
  end
end
