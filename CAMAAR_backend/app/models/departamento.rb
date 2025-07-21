##
# Modelo representando departamentos acadêmicos no sistema CAMAAR
#
# Os departamentos são unidades organizacionais que agrupam disciplinas
# e podem ter administradores associados. Representam a estrutura
# acadêmica da instituição de ensino.
#
# === Associações
# * has_many :disciplinas - Disciplinas que pertencem a este departamento
# * has_many :admins - Administradores associados a este departamento
#
# === Estrutura Hierárquica
# Departamento -> Disciplinas -> Turmas -> Alunos
#
class Departamento < ApplicationRecord
  has_many :disciplinas
  has_many :admins
end
