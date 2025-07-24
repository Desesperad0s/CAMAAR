##
# Turma
#
# Model responsável por representar turmas acadêmicas
class Turma < ApplicationRecord
  belongs_to :disciplina
  has_many :formularios
  has_many :turma_alunos
  has_many :alunos, through: :turma_alunos, source: :user
end
