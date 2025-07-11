class Formulario < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :template, optional: true
  has_many :questoes, foreign_key: :formularios_id
  has_many :respostas

  validates :name, presence: true
  validates :date, presence: true
  
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: :all_blank
end
