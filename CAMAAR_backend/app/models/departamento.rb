##
# Departamento
#
# Model responsável por representar departamentos acadêmicos.
class Departamento < ApplicationRecord
  has_many :disciplinas
  has_many :admins
end
