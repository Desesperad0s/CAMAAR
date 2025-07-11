class Questao < ApplicationRecord
  self.table_name = "questoes"
  
  belongs_to :template, foreign_key: :templates_id, inverse_of: :questoes
  belongs_to :formulario, foreign_key: :formularios_id, optional: true
  has_many :alternativas, foreign_key: :questao_id, dependent: :destroy
  has_many :respostas, class_name: 'Resposta', foreign_key: :questao_id
  
  validates :enunciado, presence: true
  
  accepts_nested_attributes_for :alternativas, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
