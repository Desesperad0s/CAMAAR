class AllowNullTemplatesIdInQuestoes < ActiveRecord::Migration[8.0]
  def change
    change_column_null :questoes, :templates_id, true
  end
end
