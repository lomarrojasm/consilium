import { Controller } from "@hotwired/stimulus"

// Completa https:// y marca visualmente si la URL es válida
export default class extends Controller {
  static targets = ["input"]

  normalize(event) {
    const input = event.target
    let value = input.value.trim()
    if (value && !/^https?:\/\//i.test(value)) value = `https://${value}`
    input.value = value
    input.classList.remove("is-valid", "is-invalid")
    if (!value) return
    try {
      const url = new URL(value)
      input.classList.add(url.hostname.includes(".") ? "is-valid" : "is-invalid")
    } catch (_) {
      input.classList.add("is-invalid")
    }
  }

  clear(event) {
    event.target.classList.remove("is-valid", "is-invalid")
  }
}
