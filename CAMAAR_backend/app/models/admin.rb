class Admin < ApplicationRecord
  belongs_to :user
  has_many :templates
   
end
