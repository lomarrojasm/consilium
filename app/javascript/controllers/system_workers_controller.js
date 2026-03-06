import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["active", "pending", "failed", "status", "failedList", "pendingList"]

  connect() {
    console.log("👷 Monitor de Workers conectado")
    this.updateStats()
    // Refrescamos los datos cada 10 segundos
    this.interval = setInterval(() => this.updateStats(), 10000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  async updateStats() {
    try {
      const response = await fetch('/admin/system_worker_stats')
      if (!response.ok) throw new Error("Error en la red")
      const data = await response.json()

      // 1. Actualizar Contadores Superiores
      this.activeTarget.textContent = data.active_workers
      this.pendingTarget.textContent = data.pending
      this.failedTarget.textContent = data.failed
      
      // 2. Actualizar Badge de Estado
      const isActive = data.active_workers > 0
      this.statusTarget.className = isActive ? 'badge bg-success' : 'badge bg-danger'
      this.statusTarget.textContent = isActive ? 'ACTIVO' : 'ALERTA'

      // 3. Renderizar Listas Detalladas
      this.renderList(this.failedListTarget, data.failed_details, 'text-danger', 'Sin errores recientes')
      this.renderList(this.pendingListTarget, data.pending_details, 'text-info', 'No hay tareas en cola')

    } catch (e) {
      console.error("Error al obtener estadísticas de workers:", e)
    }
  }

  renderList(target, items, colorClass, emptyMessage) {
    if (!items || items.length === 0) {
      target.innerHTML = `<tr><td colspan="2" class="text-center text-muted py-3 font-12">${emptyMessage}</td></tr>`
      return
    }

    target.innerHTML = items.map(item => `
      <tr>
        <td class="ps-3">
          <div class="fw-bold font-12 text-dark">${item.class}</div>
          <div class="text-muted font-11 text-truncate" style="max-width: 280px;">
            ${item.error || item.arguments || 'Sin datos'}
          </div>
        </td>
        <td class="text-end pe-3 align-middle">
          <span class="badge bg-light ${colorClass} font-10 border">${item.at}</span>
        </td>
      </tr>
    `).join('')
  }

  async retryAll() {
    if (!confirm("¿Estás seguro de que quieres reintentar todas las tareas fallidas?")) return

    try {
      const response = await fetch('/admin/retry_failed_jobs', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      
      const data = await response.json()
      
      // Feedback al usuario (puedes cambiarlo por un Toast más adelante)
      alert(data.message)
      this.updateStats()
      
    } catch (e) {
      console.error("Error al ejecutar reintento:", e)
      alert("Hubo un error al intentar reponer las tareas.")
    }
  }

  async discardAll() {
  if (!confirm("¿Estás seguro de que quieres borrar todo el historial de fallos? Esto no se puede deshacer.")) return

  try {
    const response = await fetch('/admin/discard_failed_jobs', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      }
    })
    
    const data = await response.json()
    alert(data.message)
    this.updateStats() // Refresca los contadores y las tablas
    
  } catch (e) {
    console.error("Error al limpiar historial:", e)
  }
}


}