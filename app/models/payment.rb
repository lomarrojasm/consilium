class Payment < ApplicationRecord
  belongs_to :project
  
  # Relación con ActiveStorage para subir la factura o comprobante
  has_one_attached :receipt

  # Validaciones obligatorias (No puedes registrar un pago en $0 o sin fecha)
  validates :amount, :payment_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
end