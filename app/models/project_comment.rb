class ProjectComment < ApplicationRecord
  belongs_to :project
  belongs_to :user
  
  # Relación opcional: Puede tener un destinatario o no
  belongs_to :recipient, class_name: "User", optional: true

  # DISPARADOR DE NOTIFICACIONES
  after_create :notify_project_members

  private

  def notify_project_members
    if self.recipient.present?
      # CASO A: MENSAJE DIRECTO (Solo notificar al destinatario)
      # No notificamos si el destinatario es el mismo que escribe (por si acaso)
      return if self.recipient == self.user

      Notification.create(
        recipient: self.recipient,
        actor: self.user,
        notifiable: self,
        action: "mentioned" # Acción específica para menciones
      )

    else
      # CASO B: MENSAJE GENERAL (Notificar a todo el equipo)
      recipients = project.project_members.map(&:user) - [self.user]
      
      recipients.each do |recipient|
        Notification.create(
          recipient: recipient,
          actor: self.user,
          notifiable: self,
          action: "commented"
        )
      end
    end
  end
end