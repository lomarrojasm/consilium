import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["active", "pending", "failed", "status", "failedList", "pendingList"]

  connect() {
    this.updateStats()
    this.interval = setInterval(() => this.updateStats(), 10000) // 10 segundos
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  async updateStats() {
    try {
      const response = await fetch('/admin/system_worker_stats')
      if (!response.ok) throw new Error("Error en la respuesta del servidor")
      const data = await response.json()

      // Actualizar contadores básicos
      if (this.hasActiveTarget) this.activeTarget.textContent = data.active_workers
      if (this.hasPendingTarget) this.pendingTarget.textContent = data.pending
      if (this.hasFailedTarget) this.failedTarget.textContent = data.failed
      
      // Actualizar badge de estado
      if (this.hasStatusTarget) {
        const isActive = data.active_workers > 0
        this.statusTarget.className = isActive ? 'badge bg-success' : 'badge bg-danger'
        this.statusTarget.textContent = isActive ? 'ACTIVO' : 'ALERTA'
      }

      // Renderizar las tablas de detalles (Esto corrige el error de targets faltantes)
      if (this.hasFailedListTarget) {
        this.renderList(this.failedListTarget, data.failed_details, 'text-danger', 'Sin errores recientes')
      }
      if (this.hasPendingListTarget) {
        this.renderList(this.pendingListTarget, data.pending_details, 'text-info', 'Sin tareas pendientes')
      }

    } catch (e) {
      console.error("Error al obtener estadísticas de workers:", e)
    }
  }

  renderList(target, items, colorClass, emptyMessage) {
    if (!items || items.length === 0) {
      target.innerHTML = `<tr><td colspan="2" class="text-center text-muted py-3 font-11">${emptyMessage}</td></tr>`
      return
    }

    target.innerHTML = items.map(item => `
      <tr>
        <td class="ps-3 py-2">
          <div class="fw-bold font-12 text-dark">${item.class}</div>
          <div class="text-muted font-11 text-truncate" style="max-width: 250px;">
            ${item.error || item.arguments || 'Sin descripción'}
          </div>
        </td>
        <td class="text-end pe-3 align-middle">
          <span class="badge bg-light ${colorClass} font-10 border">${item.at}</span>
        </td>
      </tr>
    `).join('')
  }

  async retryAll() {
    if (!confirm("¿Reintentar todas las tareas fallidas?")) return
    try {
      const response = await fetch('/admin/retry_failed_jobs', {
        method: 'POST',
        headers: { 
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      })
      const data = await response.json()
      alert(data.message)
      this.updateStats()
    } catch (e) { console.error(e) }
  }

  async discardAll() {
    if (!confirm("¿Borrar definitivamente el historial de fallos?")) return
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
      this.updateStats()
    } catch (e) { console.error(e) }
  }
}