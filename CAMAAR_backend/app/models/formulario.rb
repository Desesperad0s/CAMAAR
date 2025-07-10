class Formulario < ApplicationRecord
  belongs_to :turmas
  belongs_to :templates
  has_many :questoes
  has_many :respostas
end
