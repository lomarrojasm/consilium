class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    # Canal global para ver quién se conecta/desconecta
    stream_from "appearance_channel"
    
    # Canal privado para recibir órdenes de borrado o alertas personales
    stream_from "user_notifications_#{current_user.id}"

    current_user.update(online: true)
    broadcast_status("online")
  end

  def unsubscribed
    current_user.update(online: false)
    broadcast_status("offline")
  end

  private

  def broadcast_status(status)
    ActionCable.server.broadcast "appearance_channel", {
      user_id: current_user.id,
      status: status
    }
  end
end