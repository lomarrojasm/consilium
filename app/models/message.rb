class Message < ApplicationRecord
  include TimelineRecordable # <--- Para Timeline
  belongs_to :conversation
  belongs_to :user

  # Relación con ActiveStorage
  has_many_attached :attachments

  after_create :notify_recipient
  
  validates :body, presence: true, unless: -> { attachments.attached? }
  
  # Usamos messaged_at para ordenar, así el admin puede cambiar la fecha y el orden cambia
  scope :chronological, -> { order(messaged_at: :asc) }

  # Callback: Si no ponen fecha, usar la actual
  before_create :set_default_date

  private

  def set_default_date
    self.messaged_at ||= Time.current
  end

  def notify_recipient
    # 1. Validamos que el mensaje pertenezca a una conversación
    if self.conversation.present?
      chat = self.conversation


      # Obtenemos los destinatarios dependiendo de si es grupo o 1 a 1
      destinatarios = if chat.is_group?
                        chat.users.where.not(id: self.user_id)
                      else
                        [(chat.sender_id == self.user_id) ? chat.recipient : chat.sender].compact
                      end

      destinatarios.each do |destinatario|
        cache_key = "chat_#{chat.id}_user_#{destinatario.id}_online"
        esta_conectado = Rails.cache.exist?(cache_key)

        unless esta_conectado
          Notification.create(
            recipient: destinatario,
            actor: self.user,
            notifiable: self,
            action: "messaged"
          )
        end
      end
      
      # 2. Lógica para encontrar al "otro" participante:
      # Si yo (self.user) soy el que inició el chat (sender), notifico al destinatario (recipient).
      # Si yo soy el destinatario, notifico al que inició el chat (sender).
      destinatario = (chat.sender_id == self.user_id) ? chat.recipient : chat.sender

      # 3. Creamos la notificación si existe un destinatario válido
      if destinatario.present?
        # --- NUEVA LÓGICA DE SILENCIO ---
        # Verificamos si existe la marca en caché creada por Action Cable.
        # Clave: "chat_ID_user_ID_online"
        cache_key = "chat_#{chat.id}_user_#{destinatario.id}_online"
        esta_conectado = Rails.cache.exist?(cache_key)

        # 3. Solo creamos la notificación SI NO ESTÁ CONECTADO
        unless esta_conectado
          Notification.create(
            recipient: destinatario,
            actor: self.user,
            notifiable: self,   # Guardamos el mensaje como el objeto de la alerta
            action: "messaged"
          )
        end
      end

    else
      # Fallback por si acaso tienes mensajes huérfanos o lógica antigua
      Rails.logger.warn "⚠️ Mensaje #{self.id} sin conversación asociada."
    end
  end


end