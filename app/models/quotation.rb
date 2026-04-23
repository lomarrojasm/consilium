# app/models/quotation.rb
class Quotation < ApplicationRecord
  belongs_to :project
  belongs_to :client
  has_many :quotation_items, dependent: :destroy
  has_many :financial_accruals, through: :quotation_items
  belongs_to :authorized_by, class_name: "User", optional: true

  enum :status, { borrador: 0, enviado: 1, aceptado: 2, rechazado: 3, facturado: 4, pagado: 5 }

  # 2. Archivos adjuntos para esta transacción específica
  has_one_attached :pdf_document
  has_one_attached :invoice_pdf
  has_one_attached :invoice_xml

  before_create :generate_auth_code

  # 2. Método para encontrar los pagos que cubren esta cotización
  def associated_payments
    accrual_ids = quotation_items.pluck(:financial_accrual_id)
    # Buscamos pagos cuyas notas contengan el ID de nuestras actividades [REF: ID]
    Payment.where(project_id: self.project_id).select do |payment|
      accrual_ids.any? { |id| payment.notes.include?("REF: #{id}") || payment.notes.include?("id:#{id}") }
    end
  end

  def check_payment_status!
    nil if status == "pagado"

    # Si todas las actividades tienen el monto pagado completo en el cerebro financiero
    # Aquí podrías usar una lógica de comparación de montos o estatus
    # Si decides usar esta lógica, la dispararías desde el controlador de pagos
  end

  def generate_auth_code
    self.auth_code = SecureRandom.hex(10).upcase
  end
end
