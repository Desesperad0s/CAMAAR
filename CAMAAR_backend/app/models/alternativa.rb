##
# Modelo representando alternativas de questões no sistema CAMAAR
#
# As alternativas são opções de resposta para questões de múltipla escolha.
# Cada alternativa pertence a uma questão específica e contém o texto
# da opção que será apresentada aos usuários.
#
# === Associações
# * belongs_to :questao - Questão à qual esta alternativa pertence
#
# === Validações
# * content deve estar presente - O texto da alternativa é obrigatório
#
class Alternativa < ApplicationRecord
  belongs_to :questao
  
  validates :content, presence: true
end
