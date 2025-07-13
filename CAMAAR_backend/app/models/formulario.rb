class Formulario < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :template, optional: true
  has_many :respostas, dependent: :destroy
  has_many :questoes, through: :respostas

  validates :name, presence: true
  validates :date, presence: true
  
  attr_accessor :remove_missing_respostas
  
  accepts_nested_attributes_for :respostas, allow_destroy: true, reject_if: :all_blank
  
  after_update :process_remove_missing_respostas
  
  private
  
  def process_remove_missing_respostas
    if remove_missing_respostas == true || remove_missing_respostas == "1" || remove_missing_respostas == 1
      updated_resposta_ids = respostas_attributes_changed? ? 
        respostas.where("updated_at >= ?", updated_at - 5.seconds).pluck(:id) : 
        []
      
      respostas.where.not(id: updated_resposta_ids).destroy_all if updated_resposta_ids.present?
    end
  end
  
  def respostas_attributes_changed?
    previous_changes.keys.any? { |key| key.start_with?('respostas_') || key == 'respostas_attributes' }
  end
end
