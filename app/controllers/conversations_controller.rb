class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  # 1. Redirección automática para evitar el error de "Template Missing"
  def index
    @last_conversation = Conversation.where(client: @client)
                                     .involving(current_user)
                                     .order(updated_at: :desc)
                                     .first

    if @last_conversation
      redirect_to client_conversation_messages_path(@client, @last_conversation)
    else
      redirect_to client_path(@client), notice: "Aún no tienes chats activos. Inicia uno con un compañero."
    end
  end

  # 2. Redirección al index de mensajes (nuestra interfaz principal)
  def show
    @conversation = Conversation.find(params[:id])
    redirect_to client_conversation_messages_path(@client, @conversation)
  end

  def create
    recipient_id = params[:recipient_id]
    recipient_user = User.find(recipient_id)
    @conversation = Conversation.between(current_user, recipient_user, @client).first

    if @conversation.nil?
      @conversation = Conversation.create!(client: @client, sender: current_user, recipient: recipient_user, is_group: false)
      # Sincronizamos participantes para que el contador de leídos funcione
      @conversation.conversation_participants.create(user: current_user)
      @conversation.conversation_participants.create(user: recipient_user)
    end
    redirect_to client_conversation_messages_path(@client, @conversation)
  end

  def start_chat
    recipient_id = params[:recipient_id]
    @conversation = Conversation.where(client_id: @client.id)
                                .where("(sender_id = :current AND recipient_id = :recipient) OR (sender_id = :recipient AND recipient_id = :current)", 
                                      current: current_user.id, recipient: recipient_id).first

    if @conversation.nil?
      @conversation = Conversation.create!(client_id: @client.id, sender_id: current_user.id, recipient_id: recipient_id, is_group: false)
      @conversation.conversation_participants.create(user_id: current_user.id)
      @conversation.conversation_participants.create(user_id: recipient_id)
    end
    redirect_to client_conversation_messages_path(@client, @conversation)
  end

  def create_group
    user_ids = params[:user_ids] || []
    user_ids << current_user.id.to_s

    @conversation = @client.conversations.build(is_group: true, name: params[:group_name].presence || "Nuevo Grupo", sender: current_user)

    if @conversation.save
      user_ids.uniq.each { |uid| @conversation.conversation_participants.create(user_id: uid) }
      
      # Mensaje de sistema
      added_names = User.where(id: params[:user_ids]).map(&:first_name).to_sentence(last_word_connector: ' y ')
      welcome_body = "📢 #{current_user.first_name} creó el grupo '#{@conversation.name}' y añadió a: #{added_names}."
      @system_message = @conversation.messages.create!(user: current_user, body: welcome_body, messaged_at: Time.current)

      # Broadcast inicial
      html = render_to_string(partial: 'messages/message', formats: [:html], locals: { msg: @system_message, client: @client, conversation: @conversation, current_user: nil })
      ActionCable.server.broadcast("chat_channel_#{@conversation.id}", { action: "create", html: html, sender_id: @system_message.user.id })

      redirect_to client_conversation_messages_path(@client, @conversation), notice: "¡Grupo creado!"
    else
      redirect_to client_conversations_path(@client), alert: "Error al crear el grupo."
    end
  end

  def destroy
    @conversation = @client.conversations.find(params[:id])
    
    # Verificación de permisos
    can_delete = @conversation.is_group? ? (current_user.role == 'admin' || @conversation.sender_id == current_user.id) : current_user.role == 'admin'

    unless can_delete
      redirect_to client_conversation_messages_path(@client, @conversation), alert: "No tienes permiso para eliminar este chat."
      return # El return es vital para evitar el DoubleRenderError
    end

    conversation_id = @conversation.id
    participant_ids = @conversation.all_members.map(&:id)

    if @conversation.destroy
      # Notificar a otros participantes vía ActionCable
      participant_ids.each do |user_id|
        next if user_id == current_user.id
        ActionCable.server.broadcast("user_notifications_#{user_id}", { action: "remove_conversation", conversation_id: conversation_id })
      end

      # Respuesta Turbo Stream para una eliminación fluida sin recargar
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("sidebar-conv-#{conversation_id}"),
            turbo_stream.remove("sidebar-user-#{conversation_id}"), # Por si es chat individual
            turbo_stream.update("chat-window-container", partial: "messages/empty_state")
          ]
        end
        format.html { redirect_to client_conversations_path(@client), status: :see_other, notice: "Chat eliminado." }
      end
    else
      redirect_to client_conversations_path(@client), alert: "No se pudo eliminar el chat."
    end
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end
end