import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["active", "pending", "failed", "status"]

  connect() {
    this.updateStats()
    this.interval = setInterval(() => this.updateStats(), 15000) // Cada 15 segundos
  }

  disconnect() { clearInterval(this.interval) }

  async updateStats() {
    try {
      const response = await fetch('/admin/system_worker_stats')
      const data = await response.json()

      this.activeTarget.textContent = data.active_workers
      this.pendingTarget.textContent = data.pending
      this.failedTarget.textContent = data.failed
      
      // Cambiar color del badge de estado
      this.statusTarget.className = data.status === 'running' ? 'badge bg-success' : 'badge bg-danger'
      this.statusTarget.textContent = data.status === 'running' ? 'ACTIVO' : 'ALERTA'
    } catch (e) { console.error("Error en workers:", e) }
  }
}