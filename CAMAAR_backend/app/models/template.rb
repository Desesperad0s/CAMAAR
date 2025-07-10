class Template < ApplicationRecord
  belongs_to :admin, foreign_key: :admin_id
  has_many :questoes
  has_many :formularios
end
