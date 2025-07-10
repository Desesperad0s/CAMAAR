class Template < ApplicationRecord
  belongs_to :admin
  has_many :questoes
  has_many :formularios
end
