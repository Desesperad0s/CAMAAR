class Turma < ApplicationRecord
  belongs_to :disciplina
  has_many :formularios
  has_many :turmas_alunos
end
