import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggle(event) {
    // Evita comportamientos extraños al hacer click
    event.preventDefault()

    // Alternar entre 'password' y 'text'
    if (this.inputTarget.type === "password") {
      this.inputTarget.type = "text"
      // Opcional: añade una clase visual si tu CSS lo requiere
      this.element.classList.add("show-password") 
    } else {
      this.inputTarget.type = "password"
      this.element.classList.remove("show-password")
    }
  }
}