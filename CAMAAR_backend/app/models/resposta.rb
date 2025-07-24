##
# Resposta
#
# Model responsável por representar respostas de usuários a questões de formulários
class Resposta < ApplicationRecord
  self.table_name = "resposta"
  
  belongs_to :questao
  belongs_to :formulario

  validates :questao_id, presence: true
  validates :formulario_id, presence: true
  
  # A resposta precisa ter conteúdo
  validates :content, presence: true
end
