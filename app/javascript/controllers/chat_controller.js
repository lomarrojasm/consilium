import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer" // Importamos el consumer centralizado

export default class extends Controller {
  static targets = [ "messages", "input", "fileInput", "preview", "searchForm", "searchInput", "form" ]
  static values = { id: Number }

  connect() {
    console.log(`📡 Conectando al chat #${this.idValue}...`)

    this.channel = consumer.subscriptions.create(
      { channel: "ChatChannel", chat_id: this.idValue },
      {
        connected: () => console.log("✅ Chat conectado"),
        disconnected: () => console.log("❌ Chat desconectado"),
        received: (data) => {
          if (data.action === "delete") {
            const msgElement = document.getElementById(`message-${data.message_id}`)
            if (msgElement) msgElement.remove()
          } else {
            this.appendMessage(data)
          }
        }
      }
    )
    this.scrollToBottom()
  }

  // --- MANEJO DE ARCHIVOS ADJUNTOS ---

  previewFiles(event) {
    const input = event.target;
    const files = Array.from(input.files);
    const maxSize = 10 * 1024 * 1024; // 10MB
    let oversizedFiles = [];
    
    this.previewTarget.innerHTML = ""; 

    files.forEach(file => {
      if (file.size > maxSize) {
        oversizedFiles.push(file.name);
      } else {
        const iconClass = this.getFileIcon(file);
        const html = `
          <div class="d-flex align-items-center bg-white border rounded p-1 shadow-sm mb-1 animate__animated animate__fadeIn" style="width: fit-content;">
            <i class="${iconClass} font-20 me-1"></i>
            <div class="overflow-hidden" style="max-width: 120px;">
              <p class="mb-0 font-11 text-truncate fw-bold">${file.name}</p>
              <small class="text-muted" style="font-size: 9px;">(${(file.size / 1024).toFixed(1)} KB)</small>
            </div>
          </div>
        `;
        this.previewTarget.insertAdjacentHTML("beforeend", html);
      }
    });

    if (oversizedFiles.length > 0) {
      this.showSizeError(oversizedFiles);
      if (this.previewTarget.innerHTML === "") input.value = ""; 
    }
  }

  getFileIcon(file) {
    const type = file.type;
    if (type.includes('image')) return 'ri-image-line text-primary';
    if (type.includes('pdf')) return 'ri-file-pdf-line text-danger';
    if (type.includes('word') || type.includes('officedocument.wordprocessingml')) return 'ri-file-word-line text-info';
    if (type.includes('excel') || type.includes('officedocument.spreadsheetml')) return 'ri-file-excel-line text-success';
    if (type.includes('zip') || type.includes('rar')) return 'ri-file-zip-line text-warning';
    return 'ri-file-line text-muted';
  }

  showSizeError(files) {
    if (typeof Swal !== 'undefined') {
      const list = files.map(name => `<li>${name}</li>`).join('');
      Swal.fire({
        title: 'Archivo muy pesado',
        icon: 'warning',
        html: `<p class="font-13">El límite es de 10MB. No se cargarán:</p><ul class="text-start font-12 text-danger">${list}</ul>`,
        confirmButtonColor: '#3e60d5'
      });
    } else {
      alert(`Archivos demasiado grandes: ${files.join(', ')}`);
    }
  }

  // --- ENVÍO Y MENSAJES ---

  send(event) {
    event.preventDefault()
    const form = this.hasFormTarget ? this.formTarget : event.target.closest("form")
    const formData = new FormData(form)

    fetch(form.action, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content, "Accept": "application/json" },
      body: formData
    })
    .then(response => {
      if (response.ok) this.resetForm()
    })
    .catch(error => console.error("Error al enviar:", error))
  }

  resetForm() {
    this.formTarget.reset()
    if (this.hasPreviewTarget) this.previewTarget.innerHTML = ""
    this.inputTarget.focus()
    this.scrollToBottom()
  }

  appendMessage(data) {
    this.messagesTarget.insertAdjacentHTML('beforeend', data.html)
    const newMessage = this.messagesTarget.lastElementChild
    const currentUserId = document.querySelector("meta[name='current-user-id']")?.content
    
    // Alineación según el remitente
    if (String(data.sender_id) === String(currentUserId)) {
      newMessage.classList.add('odd')
    }

    this.scrollToBottom()
  }

  // --- BÚSQUEDA Y SCROLL ---

  search(event) {
    clearTimeout(this.searchTimeout)
    const input = event.target
    const form = input.closest('form')

    this.searchTimeout = setTimeout(() => {
      const query = input.value
      const url = new URL(form.action)
      url.searchParams.set('q', query)

      fetch(url, { headers: { "Accept": "application/json" } })
        .then(response => response.json())
        .then(data => {
          this.messagesTarget.innerHTML = data.html
          query.length > 0 ? this.messagesTarget.scrollTop = 0 : this.scrollToBottom()
        })
    }, 300)
  }

  scrollToBottom() {
    setTimeout(() => {
      // Intentar con SimpleBar primero, luego scroll nativo
      const simpleBar = window.SimpleBar ? window.SimpleBar.instances.get(this.messagesTarget) : null;
      if (simpleBar) {
        simpleBar.getScrollElement().scrollTop = simpleBar.getScrollElement().scrollHeight;
      } else {
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
      }
    }, 100);
  }

  // 2. Añade el método de eliminación con confirmación
  deleteMessage(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    const messageId = event.currentTarget.dataset.messageId

    Swal.fire({
      title: '¿Eliminar mensaje?',
      text: "Esta acción no se puede deshacer",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#fa5c7c', // Rojo Hyper
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, borrar',
      cancelButtonText: 'Cancelar'
    }).then((result) => {
      if (result.isConfirmed) {
        fetch(url, {
          method: "DELETE",
          headers: { 
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            "Accept": "application/json"
          }
        })
      }
    })
  }

  disconnect() {
    if (this.channel) this.channel.unsubscribe()
  }
}