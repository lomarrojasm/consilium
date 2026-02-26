class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.update(online: true)
    stream_from "appearance_channel"
    broadcast_status("online")
  end

  def unsubscribed
    # Usamos update_columns para saltar validaciones y callbacks, siendo más rápido
    current_user.update_columns(online: false, last_seen_at: Time.current)
    broadcast_status("offline")
  end

  private

  def broadcast_status(status)
    ActionCable.server.broadcast("appearance_channel", {
      user_id: current_user.id,
      status: status
    })
  end
end