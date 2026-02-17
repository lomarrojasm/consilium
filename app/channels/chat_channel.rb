class ChatChannel < ApplicationCable::Channel
 def subscribed
    # 1. Definimos la clave única: "chat_ID_usuario_ID_online"
    # Usamos el ID del chat que viene de params
    @room_id = params[:chat_id]
    stream_from "chat_channel_#{@room_id}"

    # 2. MARCAR ASISTENCIA: Guardamos que este usuario está viendo ESTE chat
    # Expira en 1 hora por seguridad (por si se cierra el navegador de golpe y no ejecuta unsubscribed)
    cache_key = "user_#{current_user.id}_in_chat_#{@room_id}"
    Rails.cache.write(cache_key, true, expires_in: 1.hour)
  end

  def unsubscribed
    # 3. BORRAR ASISTENCIA: Cuando se desconecta, borramos la marca
    cache_key = "user_#{current_user.id}_in_chat_#{@room_id}"
    Rails.cache.delete(cache_key)
    stop_all_streams
  end

  # Este método recibe datos desde el cliente (JavaScript)
  def speak(data)
    # Aquí es donde podrías integrar la lógica de Gemini más adelante
    
  end
end