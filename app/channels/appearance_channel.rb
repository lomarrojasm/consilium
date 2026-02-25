# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    # Suscribimos al usuario a una transmisión global de presencia
    stream_from "appearance_channel"
    
    # Avisamos a todos que este usuario se conectó
    broadcast_status("online")
  end

  def unsubscribed
    # Avisamos a todos que este usuario se desconectó
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