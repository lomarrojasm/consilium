import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    const userId = document.querySelector("meta[name='current-user-id']")?.content
    if (!userId) return

    this.subscription = consumer.subscriptions.create("AppearanceChannel", {
      received: (data) => {
        // 1. Manejar eliminación de chat (Turbo Stream alternativo)
        if (data.action === "remove_conversation") {
          this.handleChatRemoval(data.conversation_id)
        } 
        // 2. Manejar incremento de mensajes no leídos
        else if (data.action === "increment_unread") {
          this.handleUnreadIncrement(data.conversation_id)
        } 
        // 3. Manejar presencia (online/offline)
        else {
          this.updateStatus(data.user_id, data.status)
        }
      }
    })
  }

  handleUnreadIncrement(conversationId) {
    const badge = document.getElementById(`unread-count-${conversationId}`)
    if (badge) {
      // Obtener el valor actual, sumarle 1 y mostrarlo
      let current = parseInt(badge.innerText) || 0
      badge.innerText = current + 1
      badge.classList.remove('d-none')
      
      // Efecto visual de "pulso" para notar el cambio
      badge.style.transform = "scale(1.2)"
      badge.style.transition = "transform 0.2s ease"
      setTimeout(() => badge.style.transform = "scale(1)", 200)
    }
  }

  handleChatRemoval(id) {
    const element = document.getElementById(`sidebar-conv-${id}`) || 
                    document.getElementById(`sidebar-user-${id}`)
    if (element) {
      element.style.opacity = '0'
      element.style.transform = 'translateX(-20px)'
      element.style.transition = 'all 0.4s ease'
      setTimeout(() => element.remove(), 400)
    }
  }

  updateStatus(userId, status) {
    const dot = document.getElementById(`presence-dot-${userId}`)
    const text = document.getElementById(`presence-text-${userId}`)
    if (dot) {
      dot.className = `user-presence-dot border border-white rounded-circle bg-${status === 'online' ? 'success' : 'secondary'}`
      if (text) text.innerText = (status === 'online' ? 'En línea' : 'Desconectado')
    }
  }

  disconnect() {
    if (this.subscription) this.subscription.unsubscribe()
  }
}