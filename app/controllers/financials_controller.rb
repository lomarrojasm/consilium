class FinancialsController < ApplicationController
  before_action :set_client_and_project
  # Validamos el acceso general (Ver)
  before_action :authorize_financials_access
  # Validamos acciones que solo el admin puede hacer (Escribir/Borrar)
  before_action :authorize_admin_only, except: [:show]

  def show
    # El orden se mantiene por ID para que no salten de posición al actualizar
    @accruals_by_stage = @project.financial_accruals.order(:id).group_by(&:stage_name)
    @payments = @project.payments.order(payment_date: :desc)
  end

  def generate_template
    stages = @project.stages.order(:id) 
    
    if stages.empty?
      redirect_to client_project_financials_path(@client, @project), alert: "Atención: Primero debes generar el plan de trabajo operativo en el proyecto."
      return
    end

    stages.each_with_index do |stage, index|
      stage_name = stage.name.presence || "Etapa #{index + 1}"

      stage.activities.order(:activity_number, :id).each do |activity|
        accrual = @project.financial_accruals.find_or_initialize_by(
          stage_name: stage_name,
          concept_name: activity.name.to_s.strip
        )
        
        accrual.amount = activity.activity_cost.to_f
        
        estatus_ok = ['approved', 'aprobado', 'completado', 'terminado', 'done', 'listo p/v.b.', 'listo']
        esta_terminada = (activity.completed == true) || estatus_ok.include?(activity.status.to_s.downcase)
        
        if esta_terminada
          accrual.status = 'accrued'
          accrual.accrued_date = activity.updated_at || Date.current
        else
          accrual.status = 'pending'
        end
        
        accrual.save!
      end
    end

    redirect_to client_project_financials_path(@client, @project), notice: "Matriz sincronizada: Se recalcularon importes y se detectaron las actividades ya terminadas."
  end

  def reset_template
    @project.financial_accruals.destroy_all
    @project.payments.destroy_all
    redirect_to client_project_financials_path(@client, @project), notice: "Módulo financiero reiniciado al 100%. Todo está en ceros."
  end

  def update_accrual
    @accrual = @project.financial_accruals.find(params[:accrual_id])
    new_status = params[:status] || 'accrued'
    accrued_date = new_status == 'accrued' ? (params[:accrued_date] || Date.current) : nil

    if @accrual.update(status: new_status, accrued_date: accrued_date)
      redirect_to client_project_financials_path(@client, @project), notice: "Estatus del concepto actualizado."
    else
      redirect_to client_project_financials_path(@client, @project), alert: "Error al actualizar el concepto."
    end
  end

  def create_payment
    @payment = @project.payments.new(payment_params)
    if @payment.save
      redirect_to client_project_financials_path(@client, @project), notice: "Pago por #{helpers.number_to_currency(@payment.amount)} registrado correctamente."
    else
      redirect_to client_project_financials_path(@client, @project), alert: "Error al registrar el pago."
    end
  end

  def update_payment
    @payment = @project.payments.find(params[:payment_id])
    if @payment.update(payment_params)
      redirect_to client_project_financials_path(@client, @project), notice: "Pago actualizado correctamente."
    else
      redirect_to client_project_financials_path(@client, @project), alert: "Error al actualizar el pago."
    end
  end

  def destroy_payment
    @payment = @project.payments.find(params[:payment_id])
    @payment.destroy
    redirect_to client_project_financials_path(@client, @project), notice: "Pago eliminado del historial."
  end

  private

  def set_client_and_project
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
  end

  # Permite ver las finanzas al Admin o al Cliente dueño (funciona en Impersonate)
  def authorize_financials_access
    unless current_user.role == 'admin' || current_user.client_id == @client.id
      redirect_to client_project_path(@client, @project), alert: "No tienes permiso para acceder a esta sección."
    end
  end

  # Solo el Admin puede realizar cambios (Sincronizar, Resetear, Crear pagos, etc.)
  def authorize_admin_only
    unless current_user.role == 'admin'
      redirect_to client_project_financials_path(@client, @project), alert: "Acceso denegado: Solo administradores pueden realizar esta acción."
    end
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_date, :invoice_number, :notes, :receipt)
  end
end