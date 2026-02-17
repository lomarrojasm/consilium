class ChangeUserIdNullableInTimelineLogs < ActiveRecord::Migration[7.1]
  def change
    # Permitimos que la columna user_id acepte valores NULL
    change_column_null :timeline_logs, :user_id, true
  end
end