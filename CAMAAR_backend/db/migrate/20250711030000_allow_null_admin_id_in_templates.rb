class AllowNullAdminIdInTemplates < ActiveRecord::Migration[8.0]
  def change
    change_column_null :templates, :admin_id, true
  end
end
