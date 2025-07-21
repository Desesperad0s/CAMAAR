##
# Modelo representando turmas no sistema CAMAAR
#
# As turmas são instâncias específicas de disciplinas, oferecidas em
# semestres particulares com horários definidos. Agrupam alunos que
# cursam a mesma disciplina no mesmo período e podem ter formulários
# específicos aplicados a elas.
#
# === Associações
# * belongs_to :disciplina - Disciplina que esta turma oferece
# * has_many :formularios - Formulários aplicados a esta turma
# * has_many :turma_alunos - Associações entre turma e alunos
# * has_many :alunos, through: :turma_alunos - Alunos matriculados nesta turma
#
# === Estrutura Hierárquica
# Departamento -> Disciplinas -> Turmas -> Alunos
#
# === Atributos Típicos
# * code - Código identificador da turma
# * semester - Semestre letivo (ex: "2025/1")
# * time - Horário das aulas
# * number - Número da turma
#
class Turma < ApplicationRecord
  belongs_to :disciplina
  has_many :formularios
  has_many :turma_alunos
  has_many :alunos, through: :turma_alunos, source: :user
end
