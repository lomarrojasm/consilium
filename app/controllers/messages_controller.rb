class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :check_participation!

  def index
    @messages = @conversation.messages.order(created_at: :asc)
    
    if params[:q].present?
        @messages = @messages.where("body LIKE ?", "%#{params[:q]}%")
    end
    
    @message = @conversation.messages.new

    # Sidebar: otras conversaciones
    @conversations = @client.conversations.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
    
    @chat_partner = (@conversation.sender == current_user) ? @conversation.recipient : @conversation.sender
  end

  def create
    @client = Client.find(params[:client_id])
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # 1. Preparar el HTML para el broadcast
      html = ApplicationController.render(
        partial: 'messages/message',
        locals: { msg: @message, client: @client, conversation: @conversation, current_user: nil } 
        # Ponemos current_user: nil para que el partial NO ponga la clase 'odd'
        # Dejaremos que JS decida el lado (derecha/izquierda) en el cliente.
      )

      # 2. Enviar a TODOS los conectados a esta sala
      ActionCable.server.broadcast(
        "chat_channel_#{@conversation.id}", 
        { html: html, sender_id: @message.user.id }
      )
      
      # 3. RESPUESTA AL EMISOR (Solución Pantalla Blanca)
      respond_to do |format|
        format.json { head :ok } # Si JS lo envía, respondemos OK
        format.html { redirect_to client_conversation_messages_path(@client, @conversation) } # Fallback clásico
      end
    else
      respond_to do |format|
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.html { redirect_to client_conversation_messages_path(@client, @conversation), alert: "Error al enviar" }
      end
    end
  end

  def update
    @message = @conversation.messages.find(params[:id])
    if current_user.role == 'admin'
      if @message.update(message_params)
        redirect_to client_conversation_messages_path(@client, @conversation), notice: "Actualizado."
      end
    end
  end

  private
  
  def set_conversation
    @client = Client.find(params[:client_id])
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body, :messaged_at)
  end

  def check_participation!
    return if current_user.role == 'admin'
    return if @conversation.sender_id == current_user.id
    return if @conversation.recipient_id == current_user.id
    
    redirect_to client_path(@client), alert: "Acceso denegado al chat."
  end
end