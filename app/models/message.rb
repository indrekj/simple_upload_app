class Message < ActiveRecord::Base
  validates_length_of :body, :in => 5..100, :message => 'Liiga lühike või liiga pikk sisu'
  validates_length_of :author, :in => 5..20, :message => 'Nimi liiga lühike või liiga pikk'
end
