class Questao < ApplicationRecord
  belongs_to :template, foreign_key: :templates_id
  belongs_to :formulario, foreign_key: :formularios_id
  has_many :alternativas
  has_many :respostas
end
