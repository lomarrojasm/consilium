# app/models/project.rb
class Project < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline

  # =========================================================================
  # 1. RELACIONES: belongs_to
  # =========================================================================
  belongs_to :client
  belongs_to :user, optional: true
  belongs_to :responsible, class_name: "User", optional: true
  belongs_to :project_template, foreign_key: "template_id", optional: true

  # =========================================================================
  # 2. RELACIONES: has_many y has_one (ORDEN ESTRICTO PARA DESTROY)
  # =========================================================================

  # A. Primero se deben destruir los documentos legales y cotizaciones
  # para liberar las llaves foráneas (quotation_items) de las finanzas.
  has_one :billing_authorization, dependent: :destroy
  has_many :quotations, dependent: :destroy

  # B. Una vez liberadas las dependencias, borramos el núcleo financiero.
  has_many :financial_accruals, dependent: :destroy
  has_many :payments, dependent: :destroy

  # C. Finalmente, borramos la estructura operativa (etapas, actividades, usuarios, etc.)
  has_many :stages, -> { order(position: :asc) }, dependent: :destroy
  has_many :activities, through: :stages

  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members

  has_many :comments, class_name: "ProjectComment", dependent: :destroy
  has_many :project_comments, dependent: :destroy # Alias mantenido por retrocompatibilidad

  has_many_attached :files

  # =========================================================================
  # 3. ENUMERADORES (ESTADOS Y TIPOS)
  # =========================================================================
  enum :status, { borrador: 0, activo: 1, pausado: 2, finalizado: 3 }

  enum :project_type, {
    metodologia: "metodologia",
    especial_consultoria: "especial_consultoria",
    especial_tecnico: "especial_tecnico",
    especial_administrativo: "especial_administrativo"
  }

  # =========================================================================
  # 4. ATRIBUTOS VIRTUALES Y VALIDACIONES
  # =========================================================================
  attr_accessor :include_template

  validates :name, :start_date, presence: true

  accepts_nested_attributes_for :stages, allow_destroy: true, reject_if: :all_blank

  # =========================================================================
  # 5. CALLBACKS
  # =========================================================================
  before_validation :set_default_status
  after_create :create_default_authorization

  # =========================================================================
  # 6. MÉTODOS DE INSTANCIA (LÓGICA DE NEGOCIO)
  # =========================================================================

  # Helper para saber si es cualquier tipo de especial
  def special?
    !metodologia?
  end

  # Método para generar etapas (Llamado manualmente desde el controlador)
  def create_default_stages
    default_stages = [
      "Reunión Inicial / Kick-off",
      "Levantamiento de Requerimientos",
      "Diseño y Prototipado",
      "Desarrollo e Implementación",
      "Pruebas y QA",
      "Despliegue y Entrega"
    ]

    default_stages.each_with_index do |stage_name, index|
      stages.create(name: stage_name, position: index + 1)
    end
  end

  # Cálculo de Progreso Real (Barra de Estatus)
  def progress_percentage
    total = activities.count
    return 0 if total.zero?

    completed = activities.where(completed: true).count
    ((completed.to_f / total) * 100).round
  end

  def status_color
    case status
    when "activo" then "success"
    when "pausado" then "warning"
    when "finalizado" then "primary"
    else "secondary"
    end
  end

  # Determina si una etapa está "desbloqueada" para la vista del cliente
  def stage_unlocked?(stage)
    # 1. Si la opción secuencial está apagada, todo está desbloqueado
    return true unless sequential_stages?

    # 2. La primera etapa siempre está desbloqueada
    return true if stage == stages.first

    # 3. Una etapa se desbloquea si la ANTERIOR tiene > 90% de progreso
    previous_stage = stages.where("position < ?", stage.position).last
    previous_stage.present? && previous_stage.progress_percentage > 90
  end

  def blocked_stages
    return [] unless sequential_stages?

    stages.select do |stage|
      # Una etapa está bloqueada si no es la primera, no está desbloqueada manualmente
      # y su antecesora no ha llegado al 90%
      !stage_unlocked?(stage) && stage != stages.first
    end
  end

  # Métodos de ayuda financiera rápidos para mostrar en las vistas
  def total_accrued
    financial_accruals.already_accrued.sum(:amount)
  end

  def total_paid
    payments.sum(:amount)
  end

  def financial_balance
    total_paid - total_accrued
  end

  # =========================================================================
  # 7. MÉTODOS PRIVADOS
  # =========================================================================
  private

  def set_default_status
    self.status ||= "borrador"
  end

  def create_default_authorization
    create_billing_authorization(status: :pending)
  end
end
