##
# Questao
#
# Model responsável por representar questões de formulários e templates
class Questao < ApplicationRecord
  self.table_name = "questoes"
  
  belongs_to :template, foreign_key: :templates_id, inverse_of: :questoes, optional: true
  has_many :alternativas, foreign_key: :questao_id, dependent: :destroy
  has_many :respostas, foreign_key: :questao_id, dependent: :destroy
  has_many :formularios, through: :respostas
  
  validates :enunciado, presence: true
  
  accepts_nested_attributes_for :alternativas, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
