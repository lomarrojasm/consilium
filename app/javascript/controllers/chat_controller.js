console.log("📂 El archivo chat_controller.js se ha leído")
import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = [ "messages", "input", "form" ]
  static values = { id: Number }

  

  connect() {
    console.log(`📡 Intentando conectar al chat #${this.idValue}...`) // LOG 1

    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatChannel", chat_id: this.idValue },
      {
        connected: () => {
          console.log(`✅ ¡CONECTADO EXITOSAMENTE al canal ${this.idValue}!`) // LOG 2
        },
        disconnected: () => {
          console.log("❌ Desconectado del chat")
        },
        received: (data) => {
          console.log("📩 Mensaje recibido:", data) // LOG 3
          this.appendMessage(data)
        }
      }
    )
    this.scrollToBottom()
  }

  // ESTA ES LA CLAVE PARA EVITAR LA PANTALLA BLANCA
  send(event) {
    event.preventDefault() // Detiene la recarga de la página

    const form = event.target.closest("form")
    const formData = new FormData(form)
    const url = form.action

    // Enviamos los datos manualmente via fetch
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json" // Pedimos respuesta JSON
      },
      body: formData
    })
    .then(response => {
      if (response.ok) {
        this.inputTarget.value = "" // Limpiamos el input si se envió bien
        this.inputTarget.focus()
      } else {
        console.error("Error al enviar mensaje")
      }
    })
  }

  appendMessage(data) {
    this.messagesTarget.insertAdjacentHTML('beforeend', data.html)
    
    const newMessage = this.messagesTarget.lastElementChild
    const currentUserId = document.querySelector("meta[name='current-user-id']")?.content
    
    // Convertimos ambos a String para asegurar que la comparación funcione
    if (String(data.sender_id) === String(currentUserId)) {
      newMessage.classList.add('odd') // Derecha (Mío)
    } else {
      newMessage.classList.remove('odd') // Izquierda (Otro)
    }

    this.scrollToBottom()
  }

  scrollToBottom() {
    // Pequeño retardo para asegurar que el HTML ya se pintó
    setTimeout(() => {
      // 1. Intentamos buscar la instancia de SimpleBar en el elemento
      // (SimpleBar suele estar disponible globalmente en la plantilla Hyper)
      const simpleBar = window.SimpleBar ? window.SimpleBar.instances.get(this.messagesTarget) : null;

      if (simpleBar) {
        // 2. Si existe, usamos su método interno para obtener el contenedor real
        const scrollElement = simpleBar.getScrollElement();
        scrollElement.scrollTop = scrollElement.scrollHeight;
      } else {
        // 3. Fallback: Si no hay SimpleBar, usamos el scroll nativo
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
      }
    }, 100);
  }

  disconnect() {
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }
}