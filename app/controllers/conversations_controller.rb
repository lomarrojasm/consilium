class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  # 1. Redirección automática segura
  def index
    # Scoped finding: solo chats de este cliente e involucrando al usuario activo
    @last_conversation = @client.conversations
                                     .involving(current_user)
                                     .order(updated_at: :desc)
                                     .first

    if @last_conversation
      redirect_to client_conversation_messages_path(@client, @last_conversation)
    else
      redirect_to client_path(@client), notice: "Aún no tienes chats activos."
    end
  end

  # 2. Redirección al index de mensajes con validación de pertenencia
  def show
    # Aseguramos que la conversación pertenece al cliente de la URL
    @conversation = @client.conversations.find(params[:id])
    
    # Verificación extra: solo participantes o admin real pueden entrar
    unless true_user.role == 'admin' || @conversation.participants.include?(current_user)
      redirect_to client_path(@client), alert: "No tienes permiso para acceder a esta conversación." and return
    end

    redirect_to client_conversation_messages_path(@client, @conversation)
  end

  def create
  recipient_id = params[:recipient_id]
  recipient_user = User.find_by(id: recipient_id)

  # Misma validación de seguridad
  if recipient_user && (recipient_user.client_id == @client.id || recipient_user.role == 'admin')
    @conversation = Conversation.between(current_user, recipient_user, @client).first

    if @conversation.nil?
      @conversation = Conversation.create!(client: @client, sender: current_user, recipient: recipient_user, is_group: false)
      @conversation.conversation_participants.create(user: current_user)
      @conversation.conversation_participants.create(user: recipient_user)
    end
    redirect_to client_conversation_messages_path(@client, @conversation)
  else
    redirect_to client_conversations_path(@client), alert: "Usuario no válido."
  end
end

  def start_chat
  recipient_id = params[:recipient_id]
  
  # 1. Buscamos al usuario de forma global primero
  recipient_user = User.find_by(id: recipient_id)

  # 2. VALIDACIÓN DE SEGURIDAD: 
  # El receptor debe existir Y (ser del mismo cliente O ser un administrador)
  unless recipient_user && (recipient_user.client_id == @client.id || recipient_user.role == 'admin')
    redirect_to client_conversations_path(@client), alert: "No puedes iniciar un chat con este usuario." and return
  end

  # 3. Buscamos la conversación existente
  @conversation = Conversation.where(client_id: @client.id)
                              .where("(sender_id = :current AND recipient_id = :recipient) OR (sender_id = :recipient AND recipient_id = :current)", 
                                    current: current_user.id, recipient: recipient_user.id).first

  if @conversation.nil?
    # Creamos la conversación asegurando que se vincule al @client actual
    @conversation = Conversation.create!(
      client_id: @client.id, 
      sender_id: current_user.id, 
      recipient_id: recipient_user.id, 
      is_group: false
    )
    @conversation.conversation_participants.create(user_id: current_user.id)
    @conversation.conversation_participants.create(user_id: recipient_user.id)
  end
  
  redirect_to client_conversation_messages_path(@client, @conversation)
end

  def create_group
    user_ids = params[:user_ids] || []
    # BLINDAJE: Filtramos solo los IDs que pertenecen a este cliente para evitar inyecciones
    valid_users = User.where(client_id: @client.id, id: user_ids)
    participant_ids = valid_users.pluck(:id)
    participant_ids << current_user.id # Añadimos al creador (puede ser el admin personificando)

    @conversation = @client.conversations.build(
      is_group: true, 
      name: params[:group_name].presence || "Nuevo Grupo", 
      sender: current_user # Aparecerá el nombre del usuario personificado
    )

    if @conversation.save
      participant_ids.uniq.each { |uid| @conversation.conversation_participants.create(user_id: uid) }
      
      added_names = valid_users.map(&:first_name).to_sentence(last_word_connector: ' y ')
      welcome_body = "📢 #{current_user.first_name} creó el grupo '#{@conversation.name}' y añadió a: #{added_names}."
      @system_message = @conversation.messages.create!(user: current_user, body: welcome_body, messaged_at: Time.current)

      html = render_to_string(partial: 'messages/message', formats: [:html], locals: { msg: @system_message, client: @client, conversation: @conversation, current_user: nil })
      ActionCable.server.broadcast("chat_channel_#{@conversation.id}", { action: "create", html: html, sender_id: @system_message.user.id })

      redirect_to client_conversation_messages_path(@client, @conversation), notice: "¡Grupo creado!"
    else
      redirect_to client_conversations_path(@client), alert: "Error al crear el grupo."
    end
  end

  def destroy
    @conversation = @client.conversations.find(params[:id])
    
    # Seguridad basada en true_user para no bloquear al admin en soporte
    can_delete = @conversation.is_group? ? (true_user.role == 'admin' || @conversation.sender_id == current_user.id) : true_user.role == 'admin'

    unless can_delete
      redirect_to client_conversation_messages_path(@client, @conversation), alert: "No tienes permiso para eliminar este chat."
      return 
    end

    conversation_id = @conversation.id
    participant_ids = @conversation.all_members.map(&:id)

    if @conversation.destroy
      participant_ids.each do |user_id|
        next if user_id == current_user.id
        ActionCable.server.broadcast("user_notifications_#{user_id}", { action: "remove_conversation", conversation_id: conversation_id })
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("sidebar-conv-#{conversation_id}"),
            turbo_stream.remove("sidebar-user-#{conversation_id}"),
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
    # Lógica de IDOR centralizada: Admin real ve todo, mortales solo su empresa
    if true_user.role == 'admin'
      @client = Client.find(params[:client_id])
    else
      @client = current_user.client
      if params[:client_id].to_i != @client.id
        redirect_to root_path, alert: "Acceso no autorizado." and return
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Cliente no encontrado."
  end
end