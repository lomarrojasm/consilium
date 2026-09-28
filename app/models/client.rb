class Client < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  # Imagen de Ciente
  has_one_attached :avatar
  has_one_attached :contract

  validate :correct_avatar_mime_type

  # RELACIONES
  # Si eliminas un cliente, se eliminan sus usuarios (dependent: :destroy)
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :timeline_logs, dependent: :destroy

  # --- Muchas Conversaciones ---
  has_many :conversations, dependent: :destroy

  enum :membership, { basica: 0, gold: 1, platinum: 2 }, default: :basica

  # VALIDACIONES
  # Validamos solo lo esencial para no trabar el registro,
  # pero el RFC debe ser único para evitar duplicados.
  validates :company_name, presence: true
  validates :rfc, presence: true, uniqueness: { case_sensitive: false }

  # PRESENCIA DIGITAL: sitio web y redes sociales (URLs http/https)
  LINK_FIELDS = %i[web_page linkedin_url facebook_url instagram_url x_url youtube_url].freeze
  before_validation :normalize_links
  validates(*LINK_FIELDS, format: { with: %r{\Ahttps?://[^\s/$.?#][^\s]*\z}i, message: "no es una URL válida" }, allow_blank: true)

  # OPCIONAL: Normalizar datos antes de guardar
  before_save :upcase_rfc
  before_destroy :force_clean_ghost_logs

  private

  # Agrega https:// cuando el usuario captura solo el dominio
  def normalize_links
    LINK_FIELDS.each do |field|
      value = self[field].to_s.strip
      value = "https://#{value}" if value.present? && value !~ %r{\Ahttps?://}i
      self[field] = value.presence
    end
  end

  def force_clean_ghost_logs
    # delete_all ejecuta una consulta SQL directa y fulminante
    # garantizando que no quede nada antes de que MySQL evalúe la eliminación.
    TimelineLog.where(client_id: self.id).delete_all
  end

  def upcase_rfc
    self.rfc = rfc.upcase if rfc.present?
  end

  def correct_avatar_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png])
      errors.add(:avatar, "debe ser un archivo JPG o PNG")
    end
  end
end
