##
# Admin
#
# Model responsável por representar administradores do sistema.
class Admin < ApplicationRecord
  has_many :templates
   
end
