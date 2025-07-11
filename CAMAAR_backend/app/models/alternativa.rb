class Alternativa < ApplicationRecord
  belongs_to :questao
  
  validates :content, presence: true
end
