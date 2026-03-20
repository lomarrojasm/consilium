class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_context

  # --- SEGURIDAD AJUSTADA PARA EL FLUJO CLIENTE/SOPORTE ---
  # Ahora el cliente (y el admin en impersonate) pueden subir evidencia y hacer seguimiento
  before_action :authorize_project_member!, only: [
    :edit, :tracking, :toggle_user_approval, :toggle_admin_approval, 
    :upload_evidence, :update_status
  ]
  
  before_action :authorize_lider_or_senior!, only: [
    :new, :create, :update, :destroy, :toggle
  ]

  # Añadimos este filtro para las acciones que modifican el estado de la tarea
  before_action :check_stage_lock_on_activity!, only: [:update_status, :toggle_user_approval, :upload_evidence]

  def new
    @activity = @project.activities.build
    if params[:stage_id].present?
      stage = @project.stages.find(params[:stage_id])
      if stage.locked_for?(current_user)
        redirect_to client_project_path(@client, @project), alert: "No puedes añadir tareas a una etapa finalizada." and return
      end
      @activity.stage_id = stage.id
    end
  end

  def create
    stage = @project.stages.find(activity_params[:stage_id])
    
    # SEGURIDAD BACKEND: Evita guardar la tarea si la etapa está bloqueada para el usuario activo
    if stage.locked_for?(current_user)
      redirect_to client_project_path(@client, @project), alert: "No puedes añadir tareas a una etapa finalizada y bloqueada." and return
    end

    @activity = stage.activities.build(activity_params)
    @activity.user = current_user
    
    if @activity.save
      redirect_to client_project_path(@client, @project), notice: 'Actividad creada con éxito.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity = @project.activities.find(params[:id])
  end

  def tracking
    @activity = @project.activities.find(params[:id])
    render partial: 'activities/activity_modal', locals: { activity: @activity }, layout: false
  end

  def update
    # SEGURIDAD: Solo el admin real puede modificar la fecha de creación original
    unless current_user.role == 'admin'
      params[:activity].delete(:created_at)
    end

    if @activity.update(activity_params)
      total_cost = (@activity.leader_cost || 0) + (@activity.senior_cost || 0) + (@activity.analyst_cost || 0)
      @activity.update_column(:activity_cost, total_cost)
      redirect_to client_project_path(@client, @project), notice: 'Actividad actualizada.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to client_project_path(@client, @project), notice: 'Actividad eliminada.'
  end

  def toggle
    @activity.update(completed: !@activity.completed)
    respond_to do |format|
      format.html { redirect_to client_project_path(@client, @project), notice: "Estatus actualizado." }
      format.turbo_stream { head :ok }
    end
  end

  def upload_evidence
    if params[:activity] && params[:activity][:evidence].present?
      @activity.evidence.attach(params[:activity][:evidence])
      @activity.update(
        completed: true, 
        user: current_user, 
        completed_day: Time.current.day,
        evidence_uploaded_at: Time.current
      )
      
      # El log usa current_user: si estás personificando, guardará el nombre del cliente
      @activity.activity_logs.create!(
        user: current_user,
        status: 'pending',
        comment: "📁 Subió la evidencia formal de la actividad."
      )

      redirect_to client_project_path(@client, @project), notice: "Evidencia cargada y registrada."
    else
      redirect_to client_project_path(@client, @project), alert: "Debes adjuntar un archivo."
    end
  end

  def update_evidence_date
    @activity = Activity.find(params[:id])

    # Blindaje de seguridad: Solo permitir si el rol es admin
    if current_user.role == 'admin'
      if @activity.update(evidence_uploaded_at: params[:evidence_uploaded_at])
        redirect_back fallback_location: root_path, notice: "Fecha de evidencia actualizada correctamente."
      else
        redirect_back fallback_location: root_path, alert: "Error al actualizar la fecha."
      end
    else
      redirect_back fallback_location: root_path, alert: "No tienes permisos para modificar fechas de evidencia."
    end
  end

  def update_status
    @activity = @project.activities.find(params[:id])
    new_status = params[:status]
    comment = params[:comment]

    if @activity.update(status: new_status, completed: (new_status == 'approved'))
      log = @activity.activity_logs.create!(
        user: current_user,
        status: new_status,
        comment: comment
      )
      log.attachments.attach(params[:attachments]) if params[:attachments].present?

      redirect_to client_project_path(@client, @project), notice: "Seguimiento guardado."
    else
      redirect_to client_project_path(@client, @project), alert: "Error al guardar el seguimiento."
    end
  end

  def toggle_user_approval
    new_state = !@activity.user_approved
    updates = { user_approved: new_state, user_approved_at: new_state ? Time.current : nil }
    
    # Cascada: Si el cliente retira su aprobación, se cae la del Admin
    if !new_state
      updates[:admin_approved] = false
      updates[:admin_approved_at] = nil
    end
    
    @activity.update(updates)
    
    action_text = new_state ? "✅ Aprobó formalmente" : "↩️ Revocó la aprobación de"
    @activity.activity_logs.create!(user: current_user, status: (new_state ? 'approved' : 'pending'), comment: "#{action_text} la actividad como cliente.")

    redirect_back fallback_location: client_project_path(@client, @project), notice: "Aprobación de cliente actualizada."
  end

  def toggle_admin_approval
    # SEGURIDAD IMPERSONATE: Usamos current_user. Si entraste como cliente, no pasas de aquí.
    if current_user.role == 'admin'
      new_state = !@activity.admin_approved
      @activity.update(admin_approved: new_state, admin_approved_at: new_state ? Time.current : nil)
      
      action_text = new_state ? "🛡️ Otorgó" : "↩️ Retiró"
      @activity.activity_logs.create!(user: current_user, status: (new_state ? 'approved' : 'pending'), comment: "#{action_text} el Visto Bueno definitivo (Admin).")

      redirect_back fallback_location: client_project_path(@client, @project), notice: "Aprobación administrativa actualizada."
    else
      redirect_back fallback_location: client_project_path(@client, @project), alert: "Acceso denegado: Acción exclusiva de la administración de Consilium."
    end
  end

  private

  def set_context
    if true_user.role == 'admin'
      @client = Client.find(params[:client_id])
    else
      @client = current_user.client
      if params[:client_id].to_i != @client.id
        redirect_to root_path, alert: "Acceso denegado." and return
      end
    end

    @project = @client.projects.find(params[:project_id])
    @activity = @project.activities.find(params[:id]) if params[:id]
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Recurso no encontrado."
  end

  def authorize_project_member!
    redirect_to client_path(@client), alert: "No tienes permiso." unless true_user.role == 'admin' || @project.users.include?(current_user)
  end

  def authorize_lider_or_senior!
    role = current_project_role 
    redirect_to client_project_path(@client, @project), alert: "No tienes permisos de edición." unless true_user.role == 'admin' || ['lider', 'senior'].include?(role)
  end

  def check_stage_lock_on_activity!
    # Obtenemos la actividad
    activity = @project.activities.find(params[:id])
    
    # Si la etapa está bloqueada para el usuario actual (incluyendo impersonate)
    if activity.stage.locked_for?(current_user)
      redirect_to client_project_path(@client, @project), 
                  alert: "Acción no permitida: La etapa está finalizada y bloqueada."
    end
  end

  def activity_params
    params.require(:activity).permit(
      :name, :description, :document_ref, :stage_id, :month, :week, :completed_day, :area, :completed, :status,
      :created_at, :leader_hours, :leader_rate, :leader_cost, :senior_hours, :senior_rate, :senior_cost,
      :analyst_hours, :analyst_rate, :analyst_cost, :activity_cost, :responsible_id
    )
  end
end