# app/controllers/quotations_controller.rb
class QuotationsController < ApplicationController
  before_action :set_client_and_project, except: [ :index ]

  def new
    # Buscamos los devengos que YA están aceptados pero que NO tienen cotización
    @pending_accruals = @project.financial_accruals.accrued.where.not(id: QuotationItem.select(:financial_accrual_id))

    if @pending_accruals.empty?
      redirect_to client_project_financials_path(@client, @project), alert: "No hay actividades devengadas pendientes de cotizar."
    end

    @quotation = Quotation.new
  end

  def index
    if current_user.role == "admin"
      @quotations = Quotation.includes(:client, :project).order(created_at: :desc)
    else
      redirect_to root_path, alert: "Acceso denegado a esta sección."
    end
  end

  def create
    accrual_ids = params[:accrual_ids]

    if accrual_ids.blank?
      redirect_to new_client_project_quotation_path(@client, @project), alert: "Debes seleccionar al menos una actividad para cotizar."
      return
    end

    selected_accruals = @project.financial_accruals.where(id: accrual_ids)

    @quotation = Quotation.new(
      project: @project,
      client: @client,
      status: :borrador,
      total_amount: selected_accruals.sum(:amount),
      # Congelamos el texto legal en este momento exacto
      legal_text: BillingAuthorization::CURRENT_LEGAL_TEXT
    )

    if @quotation.save
      # Asociamos las actividades a la cotización
      selected_accruals.each do |accrual|
        @quotation.quotation_items.create!(financial_accrual: accrual)
      end
      redirect_to client_project_quotation_path(@client, @project, @quotation), notice: "Cotización #COT-#{@quotation.id} generada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @quotation = Quotation.find(params[:id])
  end

  def send_to_client
    @quotation = Quotation.find(params[:id])

    # 1. Enviamos el correo (Lo crearemos en el Paso 4)
    QuotationMailer.send_quote(@quotation).deliver_later

    # 2. Actualizamos estatus
    @quotation.update!(status: :enviado, sent_at: Time.current)

    redirect_to client_project_quotation_path(@client, @project, @quotation), notice: "Cotización enviada exitosamente al cliente."
  end

  def destroy
    @quotation = Quotation.find(params[:id])

    # Al destruir la cotización, Rails automáticamente destruye los quotation_items
    # asociados, liberando los financial_accruals para futuras cotizaciones.
    @quotation.destroy

    # Redirección inteligente
    if request.referer&.include?(all_quotations_path)
      redirect_to all_quotations_path, notice: "Cotización eliminada correctamente. Las tareas han sido liberadas."
    else
      redirect_to client_project_financials_path(@client, @project), notice: "Cotización eliminada correctamente. Las tareas han sido liberadas."
    end
  end

  def upload_invoice
    @quotation = Quotation.find(params[:id])

    if @quotation.update(invoice_params)
      # 1. Cambiamos la cotización a Facturada
      @quotation.update!(status: :facturado)

      # 2. Cambiamos todas las actividades relacionadas a "invoiced"
      @quotation.financial_accruals.update_all(status: "invoiced")

      # 3. Disparamos el correo con los adjuntos
      QuotationMailer.send_invoice(@quotation).deliver_later

      redirect_to client_project_quotation_path(@client, @project, @quotation), notice: "¡Éxito! La factura ha sido guardada y enviada automáticamente al cliente."
    else
      redirect_to client_project_quotation_path(@client, @project, @quotation), alert: "Hubo un error al adjuntar los archivos."
    end
  end

  def preview
    @quotation = Quotation.find(params[:id])
    # Usamos un layout de impresión limpio, sin sidebars ni menús
    render layout: "public"
  end

  private

  def set_client_and_project
    @client = Client.find(params[:client_id])
    @project = @client.projects.find(params[:project_id])
  end

  def invoice_params
    params.require(:quotation).permit(:invoice_pdf, :invoice_xml)
  end
end
