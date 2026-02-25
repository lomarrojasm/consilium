console.log("📂 El archivo chat_controller.js se ha leído")
import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  // Añadimos 'preview' y 'fileInput' para manejar los adjuntos
  static targets = [ "messages", "input", "fileInput", "preview", "searchInput" ]
  static values = { id: Number }

  connect() {
    console.log(`📡 Intentando conectar al chat #${this.idValue}...`)

    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatChannel", chat_id: this.idValue },
      {
        connected: () => console.log(`✅ ¡CONECTADO EXITOSAMENTE al canal ${this.idValue}!`),
        disconnected: () => console.log("❌ Desconectado del chat"),
        received: (data) => {
          console.log("📩 Mensaje recibido:", data)
          this.appendMessage(data)
        }
      }
    )
    this.scrollToBottom()
  }

  // Muestra los nombres de los archivos seleccionados antes de enviar
  previewFiles(event) {
    const input = event.target;
    const files = input.files;
    const maxSize = 10 * 1024 * 1024; // 10MB
    this.previewTarget.innerHTML = ""; 

    if (files.length > 0) {
      let oversizedFiles = [];
      
      Array.from(files).forEach(file => {
        // 1. Validar Tamaño
        if (file.size > maxSize) {
          oversizedFiles.push(file.name);
          return; 
        }

        // 2. Determinar Icono (mantenemos la lógica anterior)
        const icon = this.getFileIcon(file);
        
        // 3. Crear el Badge
        const badgeHTML = `
          <div class="badge badge-info-lighten p-2 d-flex align-items-center border border-info animate__animated animate__fadeIn">
            <i class="${icon} me-1 font-18"></i>
            <span class="text-truncate" style="max-width: 150px;">${file.name}</span>
            <small class="ms-2 opacity-75">(${(file.size / 1024).toFixed(1)} KB)</small>
          </div>
        `;
        this.previewTarget.insertAdjacentHTML('beforeend', badgeHTML);
      });

      // 4. AVISO PROFESIONAL CON SWEETALERT2
      if (oversizedFiles.length > 0) {
        const fileList = oversizedFiles.map(name => `<li>${name}</li>`).join('');
        
        Swal.fire({
          title: '<strong>Archivo muy pesado</strong>',
          icon: 'warning',
          html: `
            <p class="text-muted">El límite por archivo es de <b>10MB</b>. Los siguientes archivos no se cargarán:</p>
            <ul class="text-start font-13 text-danger">
              ${fileList}
            </ul>
          `,
          showCloseButton: true,
          focusConfirm: false,
          confirmButtonText: '<i class="ri-thumb-up-line me-1"></i> Entendido',
          confirmButtonColor: '#3e60d5', // Color azul Consilium
          background: '#fff',
          customClass: {
            popup: 'rounded-4 shadow-lg border-0',
            confirmButton: 'btn btn-primary px-4'
          },
          buttonsStyling: false
        });

        // Si todos los archivos seleccionados eran pesados, limpiamos el input
        if (this.previewTarget.innerHTML === "") {
          input.value = ""; 
        }
      }
    }
  }

  // Manejo del envío via Fetch (Soporta archivos)
  send(event) {
    event.preventDefault()

    const form = event.target.closest("form")
    const formData = new FormData(form)
    const url = form.action

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      },
      body: formData // FormData envía automáticamente los archivos (multipart/form-data)
    })
    .then(response => {
      if (response.ok) {
        this.resetForm() // Limpiamos todo tras el éxito
      } else {
        console.error("Error al enviar mensaje")
      }
    })
  }

  // Limpia el formulario y los adjuntos
  resetForm() {
    this.inputTarget.value = ""
    
    // Limpiar input de archivos si existe el target
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
    
    // Limpiar el contenedor de previsualización
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ""
    }
    
    this.inputTarget.focus()
    this.scrollToBottom()
  }

  appendMessage(data) {
    // Evitamos duplicados si el broadcast llega muy rápido (opcional)
    this.messagesTarget.insertAdjacentHTML('beforeend', data.html)
    
    const newMessage = this.messagesTarget.lastElementChild
    const currentUserId = document.querySelector("meta[name='current-user-id']")?.content
    
    if (String(data.sender_id) === String(currentUserId)) {
      newMessage.classList.add('odd')
    } else {
      newMessage.classList.remove('odd')
    }

    this.scrollToBottom()
  }

  scrollToBottom() {
    setTimeout(() => {
      const simpleBar = window.SimpleBar ? window.SimpleBar.instances.get(this.messagesTarget) : null;
      if (simpleBar) {
        simpleBar.getScrollElement().scrollTop = simpleBar.getScrollElement().scrollHeight;
      } else {
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
      }
    }, 150); // Un poco más de tiempo para archivos pesados que tardan en pintar
  }

  search(event) {
  // 1. Limpiamos el temporizador para el Debounce
  clearTimeout(this.searchTimeout)

  // 2. Guardamos la referencia al input y al form ANTES del timeout
  const input = event.target
  const form = input.closest('form')

  // 3. Verificamos que el formulario existe para evitar el error de 'action'
  if (!form) {
    console.error("❌ No se encontró el formulario de búsqueda")
    return
  }

  this.searchTimeout = setTimeout(() => {
    const query = input.value
    const url = new URL(form.action) // Ahora 'form' ya está definido con seguridad
    url.searchParams.set('q', query)

    console.log(`🔍 Buscando: "${query}" en ${url.pathname}`)

    fetch(url, {
      headers: { "Accept": "application/json" }
    })
    .then(response => {
      if (!response.ok) throw new Error("Error en la respuesta del servidor")
      return response.json()
    })
    .then(data => {
      // Reemplazamos los mensajes con el HTML filtrado
      this.messagesTarget.innerHTML = data.html
      
      // Si hay búsqueda, vamos arriba; si no, al fondo
      if (query.length > 0) {
        this.messagesTarget.scrollTop = 0
      } else {
        this.scrollToBottom()
      }
    })
    .catch(error => console.error("❌ Error en la búsqueda:", error))
  }, 300)
}

  disconnect() {
    if (this.channel) this.channel.unsubscribe()
  }
}