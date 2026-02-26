import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [ "messages", "input", "fileInput", "preview", "searchForm", "searchInput", "form" ]
  static values = { id: Number }

  connect() {
    this.channel = consumer.subscriptions.create(
      { channel: "ChatChannel", chat_id: this.idValue },
      {
        received: (data) => {
          console.log("Señal de ActionCable:", data) // Para debug

          if (data.action === "delete") {
            // Buscamos el elemento exacto
            const msgElement = document.getElementById(`message-${data.message_id}`)
            if (msgElement) {
              msgElement.style.opacity = '0'
              msgElement.style.transition = 'opacity 0.3s ease'
              setTimeout(() => {
                msgElement.remove()
                this.scrollToBottom() // Recalcular scroll
              }, 300)
            }
          } else if (data.action === "update") {
            const msgElement = document.getElementById(`message-${data.message_id}`)
            if (msgElement) {
              const dateEl = msgElement.querySelector('.text-end small:nth-child(1)')
              const timeEl = msgElement.querySelector('.text-end small:nth-child(2)')
              if (dateEl) dateEl.innerText = data.new_date
              if (timeEl) timeEl.innerText = data.new_time
              
              // Cerrar form de Bootstrap si está abierto
              const collapse = document.getElementById(`edit-date-${data.message_id}`)
              if (collapse && window.bootstrap) bootstrap.Collapse.getInstance(collapse)?.hide()
            }
          } else {
            this.appendMessage(data)
          }
        }
      }
    )
    this.scrollToBottom()
  }

  appendMessage(data) {
    this.messagesTarget.insertAdjacentHTML('beforeend', data.html)
    const newMessage = this.messagesTarget.lastElementChild
    const currentUserId = document.querySelector("meta[name='current-user-id']")?.content

    if (String(data.sender_id) === String(currentUserId)) {
      newMessage.classList.add('odd')
    }

    const dropdownToggle = newMessage.querySelector('[data-bs-toggle="dropdown"]')
    if (dropdownToggle && window.bootstrap) {
      new bootstrap.Dropdown(dropdownToggle)
    }

    this.scrollToBottom()
  }

  scrollToBottom() {
    setTimeout(() => {
      const scrollContainer = this.messagesTarget
      const simpleBar = window.SimpleBar ? window.SimpleBar.instances.get(scrollContainer) : null
      
      if (simpleBar) {
        const scrollEl = simpleBar.getScrollElement()
        scrollEl.scrollTo({ top: scrollEl.scrollHeight, behavior: 'smooth' })
      } else {
        scrollContainer.scrollTo({ top: scrollContainer.scrollHeight, behavior: 'smooth' })
      }
    }, 150)
  }

  // --- MÉTODOS DE FORMULARIO ---

  send(event) {
    event.preventDefault()
    const form = this.hasFormTarget ? this.formTarget : event.target.closest("form")
    const formData = new FormData(form)

    fetch(form.action, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content, "Accept": "application/json" },
      body: formData
    }).then(res => { if (res.ok) this.resetForm() })
  }

  resetForm() {
    this.formTarget.reset()
    if (this.hasPreviewTarget) this.previewTarget.innerHTML = ""
    this.inputTarget.focus()
    this.scrollToBottom()
  }

  previewFiles(event) {
    const input = event.target
    const files = Array.from(input.files)
    this.previewTarget.innerHTML = "" 
    files.forEach(file => {
      const html = `<div class="badge badge-info-lighten p-1 pe-2 mb-1"><i class="${file.type.includes('image') ? 'ri-image-line' : 'ri-file-line'} me-1"></i>${file.name}</div>`
      this.previewTarget.insertAdjacentHTML("beforeend", html)
    })
  }

  search(event) {
    clearTimeout(this.searchTimeout)
    const input = event.target
    const form = input.closest('form')
    this.searchTimeout = setTimeout(() => {
      const url = new URL(form.action)
      url.searchParams.set('q', input.value)
      fetch(url, { headers: { "Accept": "application/json" } })
        .then(res => res.json())
        .then(data => {
          this.messagesTarget.innerHTML = data.html
          input.value.length > 0 ? (this.messagesTarget.scrollTop = 0) : this.scrollToBottom()
        })
    }, 300)
  }

  deleteMessage(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    Swal.fire({
      title: '¿Eliminar mensaje?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#fa5c7c',
      confirmButtonText: 'Borrar'
    }).then((result) => {
      if (result.isConfirmed) {
        fetch(url, { method: "DELETE", headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content } })
      }
    })
  }

  disconnect() { if (this.channel) this.channel.unsubscribe() }
}