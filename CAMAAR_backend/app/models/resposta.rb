class Resposta < ApplicationRecord
  belongs_to :questao
  belongs_to :formulario

  validates :questao_id, presence: true
  validates :formulario_id, presence: true
  
  # A resposta precisa ter conteúdo
  validates :content, presence: true
end
