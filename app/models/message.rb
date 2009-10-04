class Message < ActiveRecord::Base
  validates_length_of :body, :in => 5..150, :message => 'Liiga lühike või liiga pikk sisu'
  validates_length_of :author, :in => 3..20, :message => 'Nimi liiga lühike või liiga pikk'
end
