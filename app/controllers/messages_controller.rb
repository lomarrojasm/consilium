class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :check_participation!

  def index
    # 1. Limpiar contador de mensajes no leídos al entrar
    @participant = @conversation.conversation_participants.find_by(user: current_user)
    @participant.update(last_read_at: Time.current) if @participant

    @company_users = User.where(client_id: @client.id)
                         .or(User.where(role: 'admin'))
                         .where.not(id: current_user.id)
                         .distinct
                         .order(:first_name)

    @messages = @conversation.messages
                             .includes(:user, attachments_attachments: :blob)
                             .order(messaged_at: :asc)

    if params[:q].present?
      query = "%#{params[:q]}%"
      @messages = @messages.joins(:user)
                           .left_outer_joins(attachments_attachments: :blob)
                           .where("messages.body LIKE :q OR users.first_name LIKE :q OR active_storage_blobs.filename LIKE :q", q: query)
                           .distinct
    end

    @message = @conversation.messages.new
    @active_conversations = Conversation.where(client_id: @client.id).involving(current_user)
    @group_conversations = @active_conversations.where(is_group: true)
    @chat_partner = (@conversation.sender == current_user) ? @conversation.recipient : @conversation.sender

    respond_to do |format|
      format.html
      format.json do
        html_content = render_to_string(partial: 'messages/message', collection: @messages, as: :msg, formats: [:html], locals: { client: @client, conversation: @conversation })
        render json: { html: html_content }
      end
    end
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user

    if @message.save
      # A. Broadcast del mensaje para la ventana de chat activa
      html = render_to_string(
        partial: 'messages/message',
        formats: [:html],
        locals: { msg: @message, client: @client, conversation: @conversation, current_user: nil }
      )
      
      ActionCable.server.broadcast("chat_channel_#{@conversation.id}", { 
        action: "create", 
        html: html, 
        sender_id: @message.user.id 
      })

      # B. Broadcast para actualizar contadores (Badges) en el sidebar de los demás
      @conversation.conversation_participants.where.not(user_id: current_user.id).each do |p|
        ActionCable.server.broadcast("user_notifications_#{p.user_id}", { 
          action: "increment_unread", 
          conversation_id: @conversation.id 
        })
      end

      respond_to do |format|
        format.json { head :ok }
        format.html { redirect_to client_conversation_messages_path(@client, @conversation) }
      end
    else
      respond_to do |format|
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.html { redirect_to client_conversation_messages_path(@client, @conversation), alert: "Error al enviar" }
      end
    end
  end

  # ... métodos update y destroy se mantienen igual a tu versión original ...
  def update
    @message = @conversation.messages.find(params[:id])
    if current_user.role == 'admin' && @message.update(message_params)
      ActionCable.server.broadcast("chat_channel_#{@conversation.id}", { 
          action: "update", message_id: @message.id,
          new_date: @message.messaged_at.strftime("%d/%m/%Y"),
          new_time: @message.messaged_at.strftime("%H:%M")
      })
      head :ok
    end
  end

  def destroy
    @message = @conversation.messages.find(params[:id])
    message_id = @message.id
    if (@message.user == current_user || current_user.role == 'admin') && @message.destroy
      ActionCable.server.broadcast("chat_channel_#{@conversation.id}", { action: "delete", message_id: message_id })
    end
    head :no_content
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
    is_part = @conversation.is_group? ? @conversation.users.include?(current_user) : (@conversation.sender_id == current_user.id || @conversation.recipient_id == current_user.id)
    redirect_to client_path(@client), alert: "Acceso denegado." unless is_part
  end
end