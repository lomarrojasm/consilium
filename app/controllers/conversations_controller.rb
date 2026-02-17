class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def index
    @users = User.where.not(id: current_user.id)
    @conversations = Conversation.where(client: @client)
                                 .where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
  end

  def show
    # Buscamos la conversación específica por su ID
    @conversation = Conversation.find(params[:id])
    @client = @conversation.client # O como tengas la relación
    
    # Cargamos los mensajes de ESA conversación
    @messages = @conversation.messages.order(messaged_at: :asc)
    
    # Inicializamos un mensaje nuevo para el formulario
    @message = Message.new
  end

  def create
    recipient_id = params[:recipient_id]
    recipient_user = User.find(recipient_id)

    # Buscamos si ya existe conversación
    @conversation = Conversation.between(current_user, recipient_user, @client).first

    if @conversation.present?
      redirect_to client_conversation_messages_path(@client, @conversation)
    else
      @conversation = Conversation.create!(
        client: @client,
        sender: current_user,
        recipient: recipient_user
      )
      redirect_to client_conversation_messages_path(@client, @conversation)
    end
  end

  def destroy
    @conversation = @client.conversations.find(params[:id])
    if current_user.role == 'admin'
      @conversation.destroy
      redirect_to client_path(@client), notice: "Conversación eliminada."
    else
      redirect_to client_path(@client), alert: "No autorizado."
    end
  end

  private
  def set_client
    @client = Client.find(params[:client_id])
  end
end