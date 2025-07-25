##
# Disciplina
#
# Model responsável por representar disciplinas acadêmicas
class Disciplina < ApplicationRecord
  belongs_to :departamento
  has_many :turmas
  
end
