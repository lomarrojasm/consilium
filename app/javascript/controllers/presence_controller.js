import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.subscription = consumer.subscriptions.create("AppearanceChannel", {
      received: (data) => {
        this.updateStatus(data.user_id, data.status)
      }
    })
  }

  disconnect() {
    this.subscription.unsubscribe()
  }

  updateStatus(userId, status) {
    // Buscamos el punto de presencia por el ID que definimos en la vista
    const dot = document.getElementById(`presence-dot-${userId}`)
    const text = document.querySelector(`#user-contact-${userId} .text-muted`)

    if (dot) {
      if (status === "online") {
        dot.classList.remove('bg-secondary')
        dot.classList.add('bg-success')
        if (text) text.innerText = 'En línea'
      } else {
        dot.classList.remove('bg-success')
        dot.classList.add('bg-secondary')
        if (text) text.innerText = 'Desconectado'
      }
    }
  }
}