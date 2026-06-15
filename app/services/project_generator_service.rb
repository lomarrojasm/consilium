# app/services/project_generator_service.rb
class ProjectGeneratorService
  def self.call(project, template_id, user)
    template = ProjectTemplate.find(template_id)

    template.stage_templates.each do |st_template|
      # 1. Crear la etapa real en el proyecto
      stage = project.stages.create!(
        name: st_template.name,
        position: st_template.position
      )

      # 2. Clonar actividades (Forzamos order(:position) para mantener el orden original del template)
      st_template.activity_templates.order(:position).each_with_index do |at, index|
        costo_calc = (at.leader_rate * at.leader_hours) +
                     (at.senior_rate * at.senior_hours) +
                     (at.analyst_rate * at.analyst_hours)

        fecha_fija = at.created_at

        # 3. Creamos la actividad de forma normal (Rails pondrá la fecha de hoy temporalmente)
        actividad = stage.activities.create!(
          name: at.name,
          month: at.month,
          week: at.week,
          document_ref: at.document_ref,
          area: at.area,
          activity_cost: costo_calc,
          leader_rate: at.leader_rate,
          senior_rate: at.senior_rate,
          analyst_rate: at.analyst_rate,
          leader_hours: at.leader_hours,
          senior_hours: at.senior_hours,
          analyst_hours: at.analyst_hours,
          user_id: user.id,
          responsible_id: user.id,
          status: "pending",
          completed: false,
          position: index # <-- Guardamos el índice secuencial al clonar
        )

        # 4. Forzamos la inyección de la fecha estática saltándonos el control de Rails
        if fecha_fija.present?
          actividad.update_columns(created_at: fecha_fija, updated_at: fecha_fija)
        end
      end
    end
  end
end
