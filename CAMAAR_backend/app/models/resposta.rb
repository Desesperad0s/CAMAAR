##
# Modelo representando respostas no sistema CAMAAR
#
# As respostas são as informações fornecidas pelos usuários para questões
# específicas dentro de formulários. Cada resposta conecta uma questão
# a um formulário específico, armazenando o conteúdo da resposta.
#
# === Associações
# * belongs_to :questao - Questão que está sendo respondida
# * belongs_to :formulario - Formulário ao qual esta resposta pertence
#
# === Validações
# * questao_id deve estar presente - Questão é obrigatória
# * formulario_id deve estar presente - Formulário é obrigatório
# * content deve estar presente - O conteúdo da resposta é obrigatório
#
# === Configurações
# * table_name = "resposta" - Define o nome da tabela no banco de dados
#
# === Relacionamento
# Uma resposta representa a interação entre um usuário e uma questão
# específica dentro do contexto de um formulário aplicado.
#
class Resposta < ApplicationRecord
  self.table_name = "resposta"
  
  belongs_to :questao
  belongs_to :formulario

  validates :questao_id, presence: true
  validates :formulario_id, presence: true
  
  # A resposta precisa ter conteúdo
  validates :content, presence: true
end
