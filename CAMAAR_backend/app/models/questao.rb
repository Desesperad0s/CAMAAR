class Questao < ApplicationRecord
  self.table_name = "questoes"
  
  belongs_to :template, foreign_key: :templates_id, inverse_of: :questoes
  belongs_to :formulario, foreign_key: :formularios_id, optional: true
  has_many :alternativas, foreign_key: :questao_id
  has_many :respostas, class_name: 'Resposta', foreign_key: :questao_id
  
  validates :enunciado, presence: true
end
