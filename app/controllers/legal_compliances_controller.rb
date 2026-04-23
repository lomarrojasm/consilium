# app/controllers/legal_compliances_controller.rb
class LegalCompliancesController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.role == "admin"
      # CORRECCIÓN: Usamos `includes(project: :client)` en lugar de `includes(:client, :project)`
      @project_authorizations = BillingAuthorization.accepted
                                                    .includes(project: :client)
                                                    .order(accepted_at: :desc)

      # Quotation SÍ tiene belongs_to :client directo, así que este se queda igual
      @accepted_quotations = Quotation.aceptado
                                      .includes(:client, :project)
                                      .order(accepted_at: :desc)
    else
      # Vista filtrada para el Cliente (Seguridad de datos)
      @project_authorizations = BillingAuthorization.accepted
                                                    .joins(:project)
                                                    .includes(project: :client) # Evita consultas N+1 en la vista
                                                    .where(projects: { client_id: current_user.client_id })
                                                    .order(accepted_at: :desc)

      @accepted_quotations = Quotation.aceptado
                                      .includes(:project)
                                      .where(client_id: current_user.client_id)
                                      .order(accepted_at: :desc)
    end
  end
end
