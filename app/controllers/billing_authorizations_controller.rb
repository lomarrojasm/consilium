# app/controllers/billing_authorizations_controller.rb
class BillingAuthorizationsController < ApplicationController
  before_action :set_client_and_project
  before_action :set_authorization
  before_action :authorize_admin_only, only: [ :edit, :update ]

  def show
    # Vista para que el cliente lea y acepte, o para ver el comprobante si ya aceptó
  end

  def edit
    # Vista exclusiva del admin para subir PDF/XML y ajustar fechas
  end

  def update
    if @authorization.update(authorization_params)
      redirect_to client_project_financials_path(@client, @project), notice: "Documentos legales y fechas actualizados correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Acción crítica: El cliente acepta los términos
  def accept
    if current_user.role == "admin"
      redirect_to client_project_billing_authorization_path(@client, @project), alert: "Un administrador no puede firmar por el cliente. Debe hacerlo el usuario del cliente."
      return
    end

    @authorization.update!(
      status: :accepted,
      accepted_at: Time.current,
      authorized_by: current_user,
      ip_address: request.remote_ip,           # Captura la IP real
      user_agent: request.user_agent,          # Captura el navegador/OS
      legal_text_version: BillingAuthorization::CURRENT_LEGAL_TEXT
    )

    # Registrar en el Timeline para auditoría
    TimelineLog.create!(
      client: @client, user: current_user, resource: @project, resource_name: @project.name,
      action_type: "legal", details: "⚖️ Autorizó legalmente la emisión de facturación. IP: #{@authorization.ip_address}",
      happened_at: Time.current
    )

    redirect_to client_project_financials_path(@client, @project), notice: "Has autorizado la facturación exitosamente. El módulo financiero ha sido desbloqueado."
  end

  private

  def set_client_and_project
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
  end

  def set_authorization
    @authorization = @project.billing_authorization || @project.create_billing_authorization
  end

  def authorization_params
    # Solo el admin pasa por aquí, permitimos manipular la fecha para proyectos antiguos y subir archivos
    params.require(:billing_authorization).permit(:accepted_at, :invoice_pdf, :invoice_xml, :legal_document)
  end

  def authorize_admin_only
    unless current_user.role == "admin"
      redirect_to client_project_financials_path(@client, @project), alert: "Acceso denegado."
    end
  end
end
