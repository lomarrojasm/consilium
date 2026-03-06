import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cpu", "ram", "disk"]

  connect() {
    this.charts = {}
    this.update()
    // Actualización cada 5 segundos para que se sienta fluido
    this.interval = setInterval(() => this.update(), 5000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  async update() {
    const metrics = [
      { id: 'system.cpu', target: this.cpuTarget, label: 'CPU', free: ['idle'], color: '#3e60d5', unit: '%' },
      { id: 'system.ram', target: this.ramTarget, label: 'RAM', free: ['free', 'avail', 'cached', 'buffers'], color: '#47adff', unit: 'GB' },
      // Restaurado a %2F (que es la barra '/' codificada) para que Netdata lo reconozca a la primera sin dar 404
      { id: 'disk_space.%2F', target: this.diskTarget, label: 'Disco', free: ['avail'], color: '#0acf97', unit: 'GB' }
    ]

    for (const m of metrics) {
      const data = await this.fetchData(m.id)
      if (data) {
        this.renderChart(m.target, m.label, data, m.free, m.color, m.unit)
      }
    }
  }

  async fetchData(chartId) {
    try {
      // Conexión directa y pura a Netdata
      const response = await fetch(`http://74.208.227.22:19999/api/v1/data?chart=${chartId}&after=-60&points=1&format=json`)
      if (!response.ok) return null
      return await response.json()
    } catch (e) { 
      return null 
    }
  }

  renderChart(canvas, label, data, freeKeys, color, fixedUnit) {
    const valuesArray = data.result || data.data
    if (!data.labels || !valuesArray || !valuesArray[0]) return

    const labels = data.labels.slice(1)
    const values = valuesArray[0].slice(1)
    
    let free = 0, used = 0

    labels.forEach((l, i) => {
      const cleanLabel = l.trim().toLowerCase()
      const valor = Number(values[i]) || 0 // Aseguramos matemática estricta

      if (freeKeys.some(k => cleanLabel.includes(k.toLowerCase()))) {
        free += valor
      } else {
        used += valor
      }
    })

    let displayUsed, displayTotal, usedPct, chartUsed, chartFree
    const total = used + free

    if (label === 'CPU') {
      usedPct = used > 100 ? "100.0" : used.toFixed(1)
      displayUsed = usedPct
      displayTotal = "100"
      chartUsed = used
      chartFree = 100 - used
      if (chartFree < 0) chartFree = 0
    } else if (label === 'RAM') {
      displayUsed = (used / 1024).toFixed(1)
      displayTotal = (total / 1024).toFixed(1)
      usedPct = total > 0 ? ((used / total) * 100).toFixed(1) : "0.0"
      chartUsed = used
      chartFree = free
    } else {
      displayUsed = used.toFixed(1)
      displayTotal = total.toFixed(1)
      usedPct = total > 0 ? ((used / total) * 100).toFixed(1) : "0.0"
      chartUsed = used
      chartFree = free
    }

    const card = canvas.closest('.card')
    if (card) {
      const isCritical = parseFloat(usedPct) > 85
      const statusClass = isCritical ? 'text-danger' : 'text-primary'
      
      const pctElement = card.querySelector('.usage-pct')
      if (pctElement) {
        pctElement.innerHTML = `
          <h2 class="fw-bold mb-0 ${statusClass}">${usedPct}%</h2>
          <div class="text-muted font-13 fw-semibold">
            <span class="text-dark">${displayUsed}</span> / ${displayTotal} ${fixedUnit}
          </div>
        `
      }
    }

    if (typeof Chart === 'undefined') return;

    if (this.charts[label]) {
      this.charts[label].data.datasets[0].data = [chartUsed, chartFree || 0.1]
      this.charts[label].update()
    } else {
      this.charts[label] = new Chart(canvas.getContext('2d'), {
        type: 'doughnut',
        data: {
          datasets: [{
            data: [chartUsed, chartFree || 0.1],
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