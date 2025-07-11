class Formulario < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :template, optional: true
  has_many :questoes, foreign_key: :formularios_id
  has_many :respostas
end
