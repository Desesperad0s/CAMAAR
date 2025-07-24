##
# Template
#
# Model responsável por representar templates de formulários.
# Gerencia estrutura de questões e alternativas padrão para novos formulários.
#
# Principais responsabilidades:
# - Armazenar dados do template (nome, descrição)
# - Relacionar templates a questões e formulários
# - Validar dados obrigatórios
#
class Template < ApplicationRecord
  belongs_to :user, foreign_key: :user_id, optional: true
  has_many :questoes, foreign_key: :templates_id, dependent: :nullify, inverse_of: :template
  has_many :formularios, foreign_key: :template_id, dependent: :nullify
  
  validates :content, presence: true
  
  accepts_nested_attributes_for :questoes, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
