class AllowNullFormulariosIdInQuestoes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :questoes, :formularios_id, true
  end
end
