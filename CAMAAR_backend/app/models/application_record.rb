##
# Classe base para todos os modelos ActiveRecord do sistema CAMAAR
#
# Esta classe herda de ActiveRecord::Base e serve como classe pai
# para todos os outros modelos da aplicação. Funciona como um ponto
# central para configurações e comportamentos compartilhados entre
# todos os modelos.
#
# === Configuração
# * primary_abstract_class - Marca esta classe como classe abstrata principal
#   do Rails 7+, permitindo múltiplas bases de dados se necessário
#
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
