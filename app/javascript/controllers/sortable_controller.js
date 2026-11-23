import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Reordena actividades dentro de una etapa o entre etapas (tbody con grupo compartido).
export default class extends Controller {
  static values = { url: String, stageId: Number }

  connect() {
    this.sortable = Sortable.create(this.element, {
      group: "activities",
      handle: ".drag-handle",
      draggable: "tr[data-activity-id]",
      filter: ".is-finalized",
      animation: 150,
      ghostClass: "bg-primary-subtle",
      emptyInsertThreshold: 30,
      onEnd: (evt) => this.persist(evt)
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  async persist(evt) {
    const row = evt.item
    const targetBody = evt.to
    const stageId = targetBody.dataset.sortableStageIdValue
    const sameList = evt.from === evt.to
    if (sameList && evt.oldIndex === evt.newIndex) return

    const ids = [...targetBody.querySelectorAll("tr[data-activity-id]")].map(tr => tr.dataset.activityId)
    const body = new URLSearchParams()
    body.append("activity_id", row.dataset.activityId)
    body.append("stage_id", stageId)
    ids.forEach(id => body.append("ids[]", id))

    try {
      const res = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body
      })
      const data = await res.json().catch(() => ({}))
      if (!res.ok) throw new Error(data.error || "No se pudo mover la actividad.")
      if (data.changed_stage) window.location.reload()
    } catch (e) {
      alert(e.message)
      window.location.reload()
    }
  }
}
