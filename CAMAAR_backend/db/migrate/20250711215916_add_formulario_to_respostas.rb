class AddFormularioToRespostas < ActiveRecord::Migration[8.0]
  def change
    add_reference :resposta, :formulario, null: false, foreign_key: true
  end
end
