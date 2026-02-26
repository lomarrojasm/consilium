// app/javascript/controllers/presence_controller.js
import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create("AppearanceChannel", {
      received: (data) => {
        this.updateStatus(data.user_id, data.status)
      }
    })

    // Detectar cuando el usuario cierra la pestaña o navega fuera
    window.addEventListener("beforeunload", () => {
      this.disconnect()
    })
  }

  disconnect() {
    if (this.subscription) {
      // Al llamar a unsubscribe, se dispara el método 'unsubscribed' en Ruby
      this.subscription.unsubscribe()
    }
  }

  updateStatus(userId, status) {
    const dot = document.getElementById(`presence-dot-${userId}`)
    const text = document.getElementById(`presence-text-${userId}`)

    if (dot) {
      if (status === "online") {
        dot.classList.add('bg-success')
        dot.classList.remove('bg-secondary')
        if (text) text.innerText = 'En línea'
      } else {
        dot.classList.add('bg-secondary')
        dot.classList.remove('bg-success')
        if (text) text.innerText = 'Desconectado'
      }
    }
  }
}