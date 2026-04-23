# app/models/billing_authorization.rb
class BillingAuthorization < ApplicationRecord
  belongs_to :project
  belongs_to :authorized_by, class_name: "User", optional: true

  enum :status, { pending: 0, accepted: 1 }

  # Archivos adjuntos para la factura y documentos legales
  has_one_attached :invoice_pdf
  has_one_attached :invoice_xml
  has_one_attached :legal_document

  # Texto legal constante (Puede venir de un I18n o BD en el futuro)
  CURRENT_LEGAL_TEXT = "Por medio de la presente, autorizo formalmente a Consilium para la emisión de la facturación correspondiente a los servicios detallados en este proyecto. Declaro que la información fiscal proporcionada es correcta y acepto los términos comerciales y de confidencialidad estipulados.".freeze

  def evidence_complete?
    accepted? && ip_address.present? && user_agent.present?
  end
end
