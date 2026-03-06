import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cpu", "ram", "disk"]

  connect() {
    this.charts = {}
    this.update()
    this.interval = setInterval(() => this.update(), 10000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  async update() {
    const metrics = [
      { id: 'system.cpu', target: this.cpuTarget, label: 'CPU', free: ['idle'], color: '#3e60d5', unit: '%' },
      { id: 'system.ram', target: this.ramTarget, label: 'RAM', free: ['free', 'avail', 'cached', 'buffers'], color: '#47adff', unit: 'GB' },
      { id: 'disk_space.%2F', target: this.diskTarget, label: 'Disco', free: ['avail'], color: '#0acf97', unit: 'GB' }
    ]

    for (const m of metrics) {
      const data = await this.fetchData(m.id)
      if (data) this.renderChart(m.target, m.label, data, m.free, m.color, m.unit)
    }
  }

  async fetchData(chartId) {
    try {
      const response = await fetch(`/admin/system_metrics_data?chart=${chartId}`)
      if (!response.ok) return null
      return await response.json()
    } catch (e) { return null }
  }

  renderChart(canvas, label, data, freeKeys, color, fixedUnit) {
    const valuesArray = data.result || data.data
    if (!data.labels || !valuesArray || !valuesArray[0]) return

    const labels = data.labels.slice(1)
    const values = valuesArray[0].slice(1)
    
    let free = 0, used = 0

    labels.forEach((l, i) => {
      const cleanLabel = l.trim().toLowerCase()
      if (freeKeys.map(k => k.toLowerCase()).includes(cleanLabel)) {
        free += values[i]
      } else {
        used += values[i]
      }
    })

    let displayUsed, displayTotal, usedPct, chartUsed, chartFree

    if (label === 'CPU') {
      usedPct = used.toFixed(1)
      displayUsed = used.toFixed(1)
      displayTotal = "100"
      chartUsed = used
      chartFree = 100 - used
    } else if (label === 'RAM') {
      // RAM viene en MiB -> Convertimos a GB
      displayUsed = (used / 1024).toFixed(1)
      displayTotal = ((used + free) / 1024).toFixed(1)
      usedPct = ((used / (used + free)) * 100).toFixed(1)
      chartUsed = used
      chartFree = free
    } else {
      // DISCO ya viene en GB/GiB -> No dividimos
      displayUsed = used.toFixed(1)
      displayTotal = (used + free).toFixed(1)
      usedPct = ((used / (used + free)) * 100).toFixed(1)
      chartUsed = used
      chartFree = free
    }

    const card = canvas.closest('.card')
    if (card) {
      const isCritical = parseFloat(usedPct) > 85
      const statusClass = isCritical ? 'text-danger' : 'text-primary'
      
      card.querySelector('.usage-pct').innerHTML = `
        <h2 class="fw-bold mb-0 ${statusClass}">${usedPct}%</h2>
        <div class="text-muted font-13 fw-semibold">
          <span class="text-dark">${displayUsed}</span> / ${displayTotal} ${fixedUnit}
        </div>
      `
    }

    if (this.charts[label]) {
      this.charts[label].data.datasets[0].data = [chartUsed, chartFree]
      this.charts[label].update()
    } else {
      this.charts[label] = new Chart(canvas.getContext('2d'), {
        type: 'doughnut',
        data: {
          datasets: [{
            data: [chartUsed, chartFree],
            backgroundColor: [color, '#f1f3fa'],
            borderWidth: 0
          }]
        },
        options: {
          maintainAspectRatio: false,
          cutout: '82%',
          plugins: { legend: { display: false }, tooltip: { enabled: false } },
          animation: { duration: 500 }
        }
      })
    }
  }
}