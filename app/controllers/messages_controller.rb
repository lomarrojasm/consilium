class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :check_participation!

  def index
    # 1. Filtro de seguridad: Usuarios de la misma empresa
    @company_users = User.where(client_id: @client.id)
                       .where.not(id: current_user.id)
                       .order(first_name: :asc)
    # 1. Cargamos relaciones y unimos tablas para la búsqueda
    @messages = @conversation.messages
                            .includes(:user, attachments_attachments: :blob)
                            .joins(:user)
                            .left_outer_joins(attachments_attachments: :blob)
                            .order(messaged_at: :asc)

    # 2. Conversación actual
    if params[:q].present?
      query = "%#{params[:q]}%"
      @messages = @messages.where(
        "messages.body LIKE :q OR 
        users.first_name LIKE :q OR 
        users.last_name LIKE :q OR 
        active_storage_blobs.filename LIKE :q OR 
        DATE_FORMAT(messages.messaged_at, '%d/%m/%Y %H:%i') LIKE :q", 
        q: query
      ).distinct
    end

    # 3. Datos para el formulario y sidebar
    @message = @conversation.messages.new
    #@conversations = @client.conversations.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
    @active_conversations = Conversation.where(client_id: @client.id).where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
    @chat_partner = (@conversation.sender == current_user) ? @conversation.recipient : @conversation.sender

    # 4. Respuesta Dual (HTML para carga inicial, JSON para búsqueda rápida)
    respond_to do |format|
      format.html # Carga normal
      format.json do
        # Forzamos a Rails a buscar el partial .html.erb aunque la petición sea JSON
        html_content = render_to_string(
          partial: 'messages/message', 
          collection: @messages, 
          as: :msg, 
          formats: [:html], # <--- ESTA ES LA CLAVE
          locals: { client: @client, conversation: @conversation }
        )
        render json: { html: html_content }
      end
    end
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

  def destroy
    @message = @conversation.messages.find(params[:id])
    
    # Solo el autor o un admin pueden borrar
    if @message.user == current_user || current_user.role == 'admin'
      @message.destroy
      
      # Avisamos al canal que el mensaje con ID X debe morir
      ChatChannel.broadcast_to(@conversation, { 
        action: "delete", 
        message_id: params[:id] 
      })
    end

    head :no_content # No necesitamos renderizar nada
  end

  private
  
  def set_conversation
    @client = Client.find(params[:client_id])
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body, :messaged_at, attachments: [])
  end

  def check_participation!
    return if current_user.role == 'admin'
    return if @conversation.sender_id == current_user.id
    return if @conversation.recipient_id == current_user.id
    
    redirect_to client_path(@client), alert: "Acceso denegado al chat."
  end
end