class Template < ApplicationRecord
  belongs_to :admin, foreign_key: :admin_id, optional: true
  has_many :questoes, foreign_key: :templates_id, dependent: :destroy, inverse_of: :template
  has_many :formularios, foreign_key: :template_id
  
  validates :content, presence: true
  
  accepts_nested_attributes_for :questoes, 
                               allow_destroy: true,
                               reject_if: :all_blank
end
