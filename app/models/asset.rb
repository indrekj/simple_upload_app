class Asset < ActiveRecord::Base
  validates_presence_of :title, :message => 'Tiitel peab olema lisatud'
  validates_presence_of :category, :message => 'Tüüp peab olema lisatud'
  validates_length_of :year, :is => 4, :message => 'Aasta peab olema neljakohaline number'

  def validate
    if file.blank? || !File.exists?(file)
      errors.add_to_base "Fail peab olema lisatud"
    elsif !['.html', '.htm', '.txt'].include?(File.extname(file))
      errors.add_to_base "Html ja txt failid ainult"
    elsif File.size(file) > 500 * 1024
      errors.add_to_base "Faili suurus peab olema alla 500KB"
    end
  end
end
