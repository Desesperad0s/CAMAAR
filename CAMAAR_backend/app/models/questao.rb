class Questao < ApplicationRecord
  belongs_to :formulario
  belongs_to :templates
  has_many :alternativas
  has_many :respostas
end
