import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "filterBtn", "pauseBtn", "search"]

  connect() {
    console.log("🚀 Terminal Consilium activa")
    this.onlyErrors = false
    this.isPaused = false
    this.searchTerm = ""
    this.rawLogs = ""
    
    this.fetchLogs()
    this.startRefreshing()
  }

  disconnect() {
    this.stopRefreshing()
  }

  // --- Gestión de Intervalos ---
  startRefreshing() {
    this.refreshTimer = setInterval(() => {
      if (!this.isPaused) this.fetchLogs()
    }, 5000)
  }

  stopRefreshing() {
    if (this.refreshTimer) clearInterval(this.refreshTimer)
  }

  // --- Comunicación con el Servidor ---
  async fetchLogs() {
    try {
      const response = await fetch('/admin/system_logs.json')
      if (!response.ok) throw new Error("Error de red")
      const data = await response.json()
      
      this.rawLogs = data.logs
      this.renderLogs()
    } catch (e) {
      console.error("Error cargando logs:", e)
      this.containerTarget.innerHTML = `<span class="text-danger">Error de conexión con el servidor de logs.</span>`
    }
  }

  // --- Lógica de Interfaz y Filtros ---
  handleSearch(event) {
    this.searchTerm = event.target.value.toLowerCase()
    this.renderLogs()
  }

  togglePause() {
    this.isPaused = !this.isPaused
    
    if (this.isPaused) {
      this.pauseBtnTarget.classList.replace('btn-outline-danger', 'btn-success')
      this.pauseBtnTarget.innerHTML = '<i class="ri-play-line"></i> Reanudar'
    } else {
      this.pauseBtnTarget.classList.replace('btn-success', 'btn-outline-danger')
      this.pauseBtnTarget.innerHTML = '<i class="ri-pause-line"></i> Pausar'
      this.fetchLogs() // Actualizar inmediatamente al quitar pausa
    }
  }

  toggleFilter() {
    this.onlyErrors = !this.onlyErrors
    
    // Cambiar estado visual del botón
    this.filterBtnTarget.classList.toggle('btn-warning', this.onlyErrors)
    this.filterBtnTarget.classList.toggle('btn-outline-warning', !this.onlyErrors)
    
    this.renderLogs()
  }

  // --- Procesamiento y Renderizado ---
  renderLogs() {
    let lines = this.rawLogs.split("\n")

    // 1. Filtrar por Errores si está activo
    if (this.onlyErrors) {
      lines = lines.filter(line => /error|fatal|exception|critical|failed/i.test(line))
    }

    // 2. Filtrar por término de búsqueda
    if (this.searchTerm) {
      lines = lines.filter(line => line.toLowerCase().includes(this.searchTerm))
    }

    // 3. Colorear y transformar a HTML
    const htmlLogs = lines.map(line => this.colorize(line)).join("\n")
    
    this.containerTarget.innerHTML = htmlLogs || "<span class='text-muted'>--- No hay registros coincidentes ---</span>"
    
    // Solo bajar el scroll si no estamos en pausa analizando algo
    if (!this.isPaused) {
      this.scrollToBottom()
    }
  }

  colorize(line) {
    // Escapar HTML para seguridad
    let safeLine = line.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    
    // Resaltar búsqueda (Highlight)
    if (this.searchTerm) {
      const regex = new RegExp(`(${this.searchTerm})`, 'gi')
      safeLine = safeLine.replace(regex, '<mark style="background: #5a4a00; color: #fff; padding: 0 2px; border-radius: 2px;">$1</mark>')
    }

    // Aplicar esquema de colores de terminal
    return safeLine
      .replace(/(DEBUG)/g, '<span style="color: #6a6a6a;">$1</span>')
      .replace(/(INFO)/g,  '<span style="color: #3e60d5;">$1</span>')
      .replace(/(WARN)/g,  '<span style="color: #ffd338;">$1</span>')
      .replace(/(ERROR|FATAL|Exception|Failed|Critical)/gi, '<span style="color: #fa5c7c; font-weight: bold;">$1</span>')
      .replace(/(Started GET|Processing by|Completed)/g, '<span style="color: #0acf97;">$1</span>')
      .replace(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/g, '<span style="color: #888;">$1</span>') // Colorear fechas
  }

  scrollToBottom() {
    this.containerTarget.scrollTop = this.containerTarget.scrollHeight
  }

  clearLogs() {
    this.containerTarget.innerHTML = "<span class='text-muted'>Consola limpiada...</span>"
  }
}