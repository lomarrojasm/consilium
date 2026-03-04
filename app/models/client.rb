class Client < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  #Imagen de Ciente
  has_one_attached :avatar

  validate :correct_avatar_mime_type

  # RELACIONES
  # Si eliminas un cliente, se eliminan sus usuarios (dependent: :destroy)
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy

  # --- Muchas Conversaciones ---
  has_many :conversations, dependent: :destroy

  enum :membership, { basica: 0, gold: 1, platinum: 2 }, default: :basica

  # VALIDACIONES
  # Validamos solo lo esencial para no trabar el registro, 
  # pero el RFC debe ser único para evitar duplicados.
  validates :company_name, presence: true
  validates :rfc, presence: true, uniqueness: { case_sensitive: false }
  
  # OPCIONAL: Normalizar datos antes de guardar
  before_save :upcase_rfc

  private

  def upcase_rfc
    self.rfc = rfc.upcase if rfc.present?
  end

  def correct_avatar_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/jpeg image/png))
      errors.add(:avatar, 'debe ser un archivo JPG o PNG')
    end
  end
  
end