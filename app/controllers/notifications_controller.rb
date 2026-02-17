class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def mark_as_read
    @notification = Notification.find(params[:id])
    
    # 1. Marcar como leído (Esto hace que baje el número en la campana automáticamente)
    @notification.update(read_at: Time.current)
    
    # 2. Redirigir a la vista correcta
    case @notification.notifiable_type
    
    when "ProjectComment"
      comment = @notification.notifiable
      # CORRECCIÓN: Redirigir a la vista de BITÁCORA (comments), no al show del proyecto
      redirect_to comments_client_project_path(comment.project.client, comment.project)
    
    when "Message"
      message = @notification.notifiable
      # Obtenemos la conversación desde el mensaje para construir la ruta
      conversation = message.conversation
      redirect_to client_conversation_messages_path(conversation.client, conversation)
    
    else
      # Fallback seguro
      redirect_back fallback_location: root_path
    end
  end
end