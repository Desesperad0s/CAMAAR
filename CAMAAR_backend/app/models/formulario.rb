##
# Modelo representando formulários do sistema CAMAAR
#
# Os formulários podem ser baseados em templates e são aplicados a turmas específicas.
# Contêm respostas que referenciam questões específicas.
# Suporta criação e atualização de respostas através de nested attributes.
#
class Formulario < ApplicationRecord
  belongs_to :turma, optional: true
  belongs_to :template, optional: true
  has_many :respostas, dependent: :destroy
  has_many :questoes, through: :respostas

  validates :name, presence: true
  validates :date, presence: true
  
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
  # Nenhum argumento direto - utiliza attr_accessor remove_missing_respostas
  #
  # === Retorno
  # Nenhum retorno específico
  #
  # === Efeitos Colaterais
  # * Remove respostas que não foram atualizadas recentemente
  # * Ação executada apenas se remove_missing_respostas estiver ativo
  # * Preserva respostas que foram atualizadas nos últimos 5 segundos
  #
  # === Funcionamento
  # 1. Verifica se remove_missing_respostas está ativo
  # 2. Coleta IDs de respostas atualizadas recentemente
  # 3. Remove respostas que não estão na lista de atualizadas
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
  # Boolean - true se atributos de respostas foram modificados, false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum - método apenas de consulta
  #
  # === Funcionamento
  # Verifica se alguma chave em previous_changes começa com 'respostas_'
  # ou é exatamente 'respostas_attributes'
  def respostas_attributes_changed?
    previous_changes.keys.any? { |key| key.start_with?('respostas_') || key == 'respostas_attributes' }
  end
end
