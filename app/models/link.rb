class Link < ActiveRecord::Base
  validates_uniqueness_of :url, :message => 'Sellise aadressiga link on juba lisatud'  
  validates_presence_of :url, :message => 'Link peab olema lisatud'
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :message => 'Kontrolli lingi formaat üle. Et algaks ikka http-ga jne.'
  validates_presence_of :description, :message => 'Paari sõnaga kirjelda lehe sisu'
    
  before_validation :limit_description
    
  protected

  def limit_description
    self[:description] = self[:description][0...80]
  end
end
