class ChatChannel < ApplicationCable::Channel
  def subscribed
    @room_id = params[:chat_id]
    # IMPORTANTE: Esta es la "frecuencia" (un string)
    stream_from "chat_channel_#{@room_id}"

    # MARCAR ASISTENCIA (Presencia)
    cache_key = "user_#{current_user.id}_in_chat_#{@room_id}"
    Rails.cache.write(cache_key, true, expires_in: 1.hour)
  end

  def unsubscribed
    cache_key = "user_#{current_user.id}_in_chat_#{@room_id}"
    Rails.cache.delete(cache_key)
    stop_all_streams
  end
end