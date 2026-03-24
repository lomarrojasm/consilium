class FinancialAccrual < ApplicationRecord
  belongs_to :project

  # Enum para manejar el estatus de manera segura
  enum :status, { pending: 'pending', accrued: 'accrued' }

  # Validaciones obligatorias
  validates :stage_name, :concept_name, :amount, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  # Scope para calcular rápidamente lo devengado
  scope :already_accrued, -> { where(status: 'accrued') }
end