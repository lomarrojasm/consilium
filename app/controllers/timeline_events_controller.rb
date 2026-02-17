class TimelineEventsController < ApplicationController
  # Ajusta la autenticación según tu sistema (Devise, etc.)
  before_action :authenticate_user! rescue nil

  def update
    # 1. Seguridad: Solo Admin puede editar fechas históricas
    # (Ajusta la validación de rol según tu modelo User)
    unless current_user.respond_to?(:admin?) ? current_user.admin? : (current_user.role == 'admin' || current_user.role == 2)
      return redirect_back fallback_location: root_path, alert: "No tienes permisos para modificar el historial."
    end

    # 2. Obtener datos del formulario
    log_id = params[:log_id]
    new_date_str = params[:new_date]
    
    # Convertir string a objeto DateTime
    new_date = Time.zone.parse(new_date_str) rescue Time.current

    # 3. Buscar el Log en la tabla unificada
    log = TimelineLog.find(log_id)

    ActiveRecord::Base.transaction do
      # A) Actualizamos la fecha VISUAL en el Timeline
      log.update_column(:happened_at, new_date)

      # B) Actualizamos la fecha REAL en el recurso original (Proyecto, Actividad, Chat)
      if log.resource
        # Determinamos qué columna fecha usa ese modelo
        date_column = case log.resource_type
                      when 'Activity' then :updated_at # Las actividades usan fecha de finalización
                      when 'Message'  then :created_at
                      else :created_at # Projects, Members, Comments
                      end
        
        # Usamos update_column para saltar callbacks y evitar que se cree OTRO log de "update"
        log.resource.update_column(date_column, new_date)
        
        # Si es mensaje, a veces tienen messaged_at, lo actualizamos también si existe
        if log.resource_type == 'Message' && log.resource.has_attribute?(:messaged_at)
          log.resource.update_column(:messaged_at, new_date)
        end
      end
    end

    redirect_back fallback_location: root_path, notice: "Fecha del evento actualizada correctamente."
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: "El evento no se encontró."
  rescue => e
    redirect_back fallback_location: root_path, alert: "Error: #{e.message}"
  end
end