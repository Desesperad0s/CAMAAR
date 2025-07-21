##
# Modelo representando questões no sistema CAMAAR
#
# As questões são componentes fundamentais dos templates e formulários.
# Cada questão possui um enunciado e pode ter múltiplas alternativas
# (para questões de múltipla escolha). As questões pertencem a templates
# e recebem respostas através dos formulários.
#
# === Associações
# * belongs_to :template - Template ao qual esta questão pertence
# * has_many :alternativas - Alternativas de resposta (múltipla escolha)
# * has_many :respostas - Respostas dadas a esta questão
# * has_many :formularios, through: :respostas - Formulários que contêm esta questão
#
# === Validações
# * enunciado deve estar presente - O texto da questão é obrigatório
#
# === Configurações
# * table_name = "questoes" - Define o nome da tabela no banco de dados
# * accepts_nested_attributes_for :alternativas - Permite criar/editar alternativas junto com a questão
#
class Questao < ApplicationRecord
  self.table_name = "questoes"
  
  belongs_to :template, foreign_key: :templates_id, inverse_of: :questoes
  has_many :alternativas, foreign_key: :questao_id, dependent: :destroy
  has_many :respostas, foreign_key: :questao_id, dependent: :destroy
  has_many :formularios, through: :respostas
  
  validates :enunciado, presence: true
  
  accepts_nested_attributes_for :alternativas, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
