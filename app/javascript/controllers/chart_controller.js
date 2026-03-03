import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "canvas" ]
  static values = { scores: Array }

  connect() {
    this.ensureChartLib()
  }

  ensureChartLib() {
    // 1. ¿Ya existe la librería?
    if (typeof window.Chart !== 'undefined' || typeof Chart !== 'undefined') {
      this.renderChart()
      return
    }

    // 2. ¿Ya la estamos descargando? (Evita duplicados)
    if (document.getElementById('chartjs-cdn')) {
      setTimeout(() => this.ensureChartLib(), 200)
      return
    }

    // 3. Si no existe, la descargamos nosotros mismos
    console.log("🛠️ Chart.js no detectado. Iniciando descarga dinámica...")
    const script = document.createElement('script')
    script.id = 'chartjs-cdn'
    script.src = 'https://cdn.jsdelivr.net/npm/chart.js'
    script.async = true
    
    // Cuando termine de cargar, disparamos el render
    script.onload = () => {
      console.log("✅ Chart.js cargado exitosamente vía dinámica.")
      this.renderChart()
    }

    document.head.appendChild(script)
  }

  renderChart() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext('2d')
    
    // Usamos window.Chart explícitamente para mayor seguridad
    const ChartLib = window.Chart

    const existingChart = ChartLib.getChart(canvas)
    if (existingChart) existingChart.destroy()

    console.log("🎨 Pintando telaraña con:", this.scoresValue)

    new ChartLib(ctx, {
      type: 'radar',
      data: {
        labels: ['Estrategia', 'Finanzas', 'Operaciones', 'Ventas', 'C. Humano'],
        datasets: [{
          label: 'Nivel de Madurez',
          data: this.scoresValue,
          fill: true,
          backgroundColor: 'rgba(99, 102, 241, 0.3)',
          borderColor: '#6366f1',
          pointBackgroundColor: '#6366f1',
          pointBorderColor: '#fff',
          pointRadius: 5,
          borderWidth: 3
        }]
      },
      options: {
        animation: {
          // Si detectamos que estamos en modo impresión o captura, desactivamos la animación
          duration: (window.matchMedia('print').matches || navigator.userAgent.includes('HeadlessChrome')) ? 0 : 1000
        },
        responsive: true,
        devicePixelRatio: 2,
        maintainAspectRatio: false,
        scales: {
          r: {
            min: 0,
            max: 5,
            ticks: { stepSize: 1, display: true, backdropColor: 'transparent' },
            grid: { color: 'rgba(0,0,0,0.1)' },
            pointLabels: { font: { size: 12, weight: 'bold' }, color: '#475569' }
          }
        },
        plugins: { legend: { display: false } }
      }
    })
  }
}