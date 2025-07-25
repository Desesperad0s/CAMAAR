
##
# Formulario
#
# Model responsável por representar formulários aplicados a turmas
class Formulario < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :template, optional: true
  has_many :respostas, dependent: :destroy
  has_many :questoes, through: :respostas

  validates :name, presence: true
  validates :date, presence: true
  validates :publico_alvo, presence: true, inclusion: { in: %w[docente discente] }
  
  attr_accessor :remove_missing_respostas
  
  accepts_nested_attributes_for :respostas, 
                               allow_destroy: true, 
                               reject_if: :all_blank, 
                               update_only: true
  
  after_update :process_remove_missing_respostas
  
  private
  
  ##
  # Processa a remoção de respostas ausentes após atualização
  #
  # === Argumentos
  # Nenhum argumento direto, utiliza attr_accessor remove_missing_respostas
  #
  # === Retorno
  # Nenhum retorno específico
  #
  # === Efeitos Colaterais
  # * Remove respostas que não foram atualizadas recentemente
  # * Ação executada apenas se remove_missing_respostas estiver ativo
  # * Preserva respostas que foram atualizadas nos últimos 5 segundos
  #
  def process_remove_missing_respostas
    return unless remove_missing_respostas == true || remove_missing_respostas == "1" || remove_missing_respostas == 1
    
    updated_resposta_ids = []
    if respostas_attributes_changed?
      updated_resposta_ids = respostas.where("updated_at >= ?", updated_at - 5.seconds).pluck(:id)
    end
    
    if updated_resposta_ids.present?
      respostas.where.not(id: updated_resposta_ids).destroy_all
    end
  end
  
  ##
  # Verifica se os atributos de respostas foram alterados
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # Boolean: true se atributos de respostas foram modificados, false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum
  #
  def respostas_attributes_changed?
    previous_changes.keys.any? { |key| key.start_with?('respostas_') || key == 'respostas_attributes' }
  end
end
