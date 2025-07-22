class AddPublicoAlvoToFormularios < ActiveRecord::Migration[7.0]
  def change
    add_column :formularios, :publico_alvo, :string, null: false, default: "discente"
  end
end
