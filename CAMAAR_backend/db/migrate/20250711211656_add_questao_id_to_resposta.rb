class AddQuestaoIdToResposta < ActiveRecord::Migration[8.0]
  def change
    add_reference :resposta, :questao, null: false, foreign_key: true
  end
end
