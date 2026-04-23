# app/controllers/public_quotations_controller.rb
class PublicQuotationsController < ApplicationController
  # Evitamos pedir login
  skip_before_action :authenticate_user!, raise: false

  # Usamos un layout público (sin menú lateral)
  layout "public"

  def show
    @quotation = Quotation.find_by!(auth_code: params[:code])
  end

  def authorize
    @quotation = Quotation.find_by!(auth_code: params[:code])

    if @quotation.aceptado?
      redirect_to public_quotation_path(code: @quotation.auth_code), alert: "Esta cotización ya había sido autorizada previamente."
      return
    end

    @quotation.update!(
      status: :aceptado,
      accepted_at: Time.current,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    # Avisamos al Admin que ya puede facturar
    QuotationMailer.quote_authorized(@quotation).deliver_later

    redirect_to public_quotation_path(code: @quotation.auth_code), notice: "Cotización autorizada legalmente. El equipo de Consilium ha sido notificado."
  end
end
