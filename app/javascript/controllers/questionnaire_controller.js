import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "progressBar", "progressText", "currentNum", "prevBtn", "nextBtn", "submitBtn"]

  connect() {
    this.currentStep = 0
    this.totalSteps = this.stepTargets.length
    this.updateUI()
  }

  next(event) {
    if (event) event.preventDefault()

    // --- VALIDACIÓN CON SWEETALERT2 ---
    const currentStepFields = this.stepTargets[this.currentStep].querySelectorAll("input[required], textarea[required]")
    let allValid = true

    currentStepFields.forEach(field => {
      if (!field.value.trim()) {
        allValid = false
        field.classList.add("is-invalid")
      } else {
        field.classList.remove("is-invalid")
      }
    })

    if (!allValid) {
      Swal.fire({
        title: '¡Espera!',
        text: 'Por favor, responde la pregunta antes de continuar.',
        icon: 'warning',
        confirmButtonColor: '#6366f1',
        confirmButtonText: 'Entendido'
      })
      return
    }
    // ----------------------------------

    if (this.currentStep < this.totalSteps - 1) {
      this.currentStep++
      this.updateUI()
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
  }

  prev(event) {
    if (event) event.preventDefault()
    if (this.currentStep > 0) {
      this.currentStep--
      this.updateUI()
    }
  }

  updateUI() {
    // Mostrar/Ocultar pasos
    this.stepTargets.forEach((el, i) => {
      el.classList.toggle("d-none", i !== this.currentStep)
    })

    // Actualizar Contador (Asegúrate de que el target existe en el HTML)
    if (this.hasCurrentNumTarget) {
      this.currentNumTarget.innerText = this.currentStep + 1
    }

    // Actualizar Progreso
    const percent = Math.round((this.currentStep / (this.totalSteps - 1)) * 100)
    if (this.hasProgressBarTarget) this.progressBarTarget.style.width = `${percent}%`
    if (this.hasProgressTextTarget) this.progressTextTarget.innerText = `${percent}%`

    // Control de botones
    if (this.hasPrevBtnTarget) this.prevBtnTarget.classList.toggle("d-none", this.currentStep === 0)
    if (this.hasNextBtnTarget) this.nextBtnTarget.classList.toggle("d-none", this.currentStep === this.totalSteps - 1)
    if (this.hasSubmitBtnTarget) this.submitBtnTarget.classList.toggle("d-none", this.currentStep !== this.totalSteps - 1)
  }
}