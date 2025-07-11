class AddQuestaoIdToAlternativas < ActiveRecord::Migration[8.0]
  def change
    add_reference :alternativas, :questao, null: false, foreign_key: true
  end
end
