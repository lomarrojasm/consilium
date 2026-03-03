import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "nextBtn", "prevBtn", "submitBtn", "progressBar", "progressText", "currentNum"]

  connect() {
    this.currentStep = 0
    this.showStep(this.currentStep)
  }

  // Avanza automáticamente al seleccionar una calificación (Radio Buttons)
  autoNext() {
    // Un pequeño delay de 180ms permite que el usuario vea el cambio visual 
    // de su selección antes de que la pantalla cambie.
    setTimeout(() => {
      this.next()
    }, 180)
  }

  next() {
    if (this.validateStep()) {
      if (this.currentStep < this.stepTargets.length - 1) {
        this.currentStep++
        this.showStep(this.currentStep)
      }
    } else {
      // Alerta estética si falta información
      Swal.fire({
        title: '¡Información pendiente!',
        text: 'Por favor, completa los campos requeridos para continuar.',
        icon: 'warning',
        confirmButtonColor: '#6366f1',
        confirmButtonText: 'Entendido',
        heightAuto: false // Evita saltos visuales en móviles
      })
    }
  }

  prev() {
    if (this.currentStep > 0) {
      this.currentStep--
      this.showStep(this.currentStep)
    }
  }

  showStep(index) {
    // Alternar visibilidad de los pasos
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("d-none", i !== index)
    })

    // LÓGICA DE NAVEGACIÓN
    // 1. Mostrar "Anterior" siempre, excepto en el primer paso
    this.prevBtnTarget.classList.toggle("d-none", index === 0)
    
    // 2. Mostrar "Siguiente" SOLO en el paso 0 (donde hay inputs de texto/email)
    // En las preguntas 1-25, desaparece porque el avance es automático (autoNext)
    this.nextBtnTarget.classList.toggle("d-none", index !== 0)

    // 3. Mostrar "Enviar" solo en el paso final
    this.submitBtnTarget.classList.toggle("d-none", index !== this.stepTargets.length - 1)

    this.updateProgress(index)
    
    // Auto-scroll al inicio de la tarjeta al cambiar de paso (útil en móviles)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  updateProgress(index) {
    const totalSteps = this.stepTargets.length - 1
    const percent = Math.round((index / totalSteps) * 100)
    
    if (this.hasProgressBarTarget) this.progressBarTarget.style.width = `${percent}%`
    if (this.hasProgressTextTarget) this.progressTextTarget.innerHTML = `${percent}%`
    if (this.hasCurrentNumTarget) this.currentNumTarget.innerHTML = index + 1
  }

  validateStep() {
    const currentStepEl = this.stepTargets[this.currentStep]
    
    // A. Validar Inputs de texto/email (Paso 0)
    const inputs = currentStepEl.querySelectorAll('input[required], textarea[required]')
    for (let input of inputs) {
      if (!input.value.trim()) return false
      // Validación simple de email
      if (input.type === 'email' && !input.value.includes('@')) return false
    }

    // B. Validar Radio Buttons (Pasos de calificación)
    const radios = currentStepEl.querySelectorAll('input[type="radio"]')
    if (radios.length > 0) {
      const name = radios[0].getAttribute('name')
      const checked = currentStepEl.querySelector(`input[name="${name}"]:checked`)
      if (!checked) return false
    }

    return true
  }
}