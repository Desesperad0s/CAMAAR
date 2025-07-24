##
# Alternativa
#
# Model responsável por representar alternativas de questões

class Alternativa < ApplicationRecord
  belongs_to :questao
  
  validates :content, presence: true
end
