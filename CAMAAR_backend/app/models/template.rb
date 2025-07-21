##
# Modelo representando templates de formulários do sistema CAMAAR
#
# Os templates servem como modelos para criação de formulários.
# Contêm questões que podem ser reutilizadas em múltiplos formulários.
# São criados por usuários (professores ou administradores) e podem
# ser aplicados a diferentes turmas através dos formulários.
#
class Template < ApplicationRecord
  belongs_to :user, foreign_key: :user_id, optional: true
  has_many :questoes, foreign_key: :templates_id, dependent: :destroy, inverse_of: :template
  has_many :formularios, foreign_key: :template_id
  
  validates :content, presence: true
  
  accepts_nested_attributes_for :questoes, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
