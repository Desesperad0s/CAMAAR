##
# Modelo representando administradores do sistema CAMAAR
#
# Os administradores são usuários com privilégios especiais que podem
# criar e gerenciar templates de formulários. Este modelo parece estar
# sendo descontinuado em favor do sistema de roles no modelo User.
#
# === Associações
# * has_many :templates - Templates criados pelo administrador
#
class Admin < ApplicationRecord
  has_many :templates
   
end
