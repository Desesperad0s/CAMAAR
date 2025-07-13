class Resposta < ApplicationRecord
  belongs_to :questao
  belongs_to :formulario

  validates :questao_id, presence: true
  validates :formulario_id, presence: true
  
  # Prevent duplicate associations between the same form and question
  validates :questao_id, uniqueness: { scope: :formulario_id }
end
