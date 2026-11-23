class BackfillActivityPositions < ActiveRecord::Migration[8.0]
  # Asigna position consecutiva (por etapa) a las actividades que la tienen vacía,
  # respetando el orden histórico: semana y luego id.
  def up
    stage_ids = select_values("SELECT DISTINCT stage_id FROM activities WHERE position IS NULL")
    stage_ids.each do |stage_id|
      rows = select_rows("SELECT id FROM activities WHERE stage_id = #{stage_id.to_i} ORDER BY position IS NULL, position, week, id")
      rows.each_with_index do |(id), i|
        execute("UPDATE activities SET position = #{i} WHERE id = #{id.to_i}")
      end
    end
  end

  def down; end
end
