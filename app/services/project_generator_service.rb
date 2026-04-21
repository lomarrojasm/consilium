# app/services/project_generator_service.rb
class ProjectGeneratorService
  # El método 'call' es la convención estándar para los Service Objects en Ruby
  def self.call(project, template_id, user)
    template = ProjectTemplate.find(template_id)

    template.stage_templates.each do |st_template|
      # 1. Crear la etapa real en el proyecto
      stage = project.stages.create!(
        name: st_template.name,
        position: st_template.position
      )

      # 2. Clonar actividades del template a actividades reales
      st_template.activity_templates.each do |at|
        costo_calc = (at.leader_rate * at.leader_hours) +
                     (at.senior_rate * at.senior_hours) +
                     (at.analyst_rate * at.analyst_hours)

        stage.activities.create!(
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
          status: "pending"
        )
      end
    end
  end
end
