class AddTemplateIdToFormularios < ActiveRecord::Migration[8.0]
  def change
    add_reference :formularios, :template, null: true, foreign_key: true
  end
end
