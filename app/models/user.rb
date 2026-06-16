class User < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  # ASOCIACIONES
  # optional: true permite que exista un "Super Admin" (tú) que no pertenezca
  # a ninguna empresa cliente, o para usuarios de soporte interno.
  belongs_to :client, optional: true

  # DEVISE
  # :invitable -> Permite invitar usuarios por correo.
  # :trackable -> Guarda IP, hora de entrada y conteo de logins.
  # :registerable -> ELIMINADO (Nadie puede registrarse solo).
  devise :invitable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable

  has_one_attached :avatar
  has_many :messages, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :activity_logs, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations_as_recipient, class_name: "Conversation", foreign_key: "recipient_id", dependent: :destroy
  has_many :conversations_as_sender, class_name: "Conversation", foreign_key: "sender_id", dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :timeline_logs, dependent: :destroy
  has_many :projects_as_responsible, class_name: "Project", foreign_key: "responsible_id", dependent: :nullify

  # ROLES (Enum)
  # Esto permite usar métodos como: user.admin? o user.user?
  # En base de datos se guarda como 0 o 1, pero Rails lo trata como texto.
  enum :role, { user: 0, admin: 1, manager: 2 }, default: :user

  # VALIDACIONES
  validates :first_name, :last_name, presence: true



  # Validar que si NO es un admin del sistema (sin cliente), tenga un cliente asignado.
  # Descomenta esto si quieres obligar a que todos (menos tú) tengan empresa.
  # validates :client_id, presence: true, unless: -> { email == 'admin@hyper.com' }

  # MÉTODOS DE AYUDA
  def full_name
    "#{first_name} #{last_name}"
  end

  # Método para mostrar en el dashboard (Avatar con iniciales)
  def initials
    "#{first_name.first}#{last_name.first}".upcase
  end
end
