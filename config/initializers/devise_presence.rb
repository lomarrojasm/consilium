Warden::Manager.before_logout do |user, auth, opts|
  # Este código se ejecuta justo antes de que el usuario salga
  user.update(online: false, last_seen_at: Time.current) if user
  
  # Opcional: Avisar manualmente al canal
  ActionCable.server.broadcast("appearance_channel", { 
    user_id: user.id, 
    status: "offline" 
  })
end