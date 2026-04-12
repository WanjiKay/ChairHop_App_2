import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "submit"]

  check() {
    const email = this.fieldTarget.value.trim()
    if (!email) return

    fetch(`/users/check_email?email=${encodeURIComponent(email)}`)
      .then(r => r.json())
      .then(({ available }) => {
        if (available) {
          this.submitTarget.disabled = false
          this.fieldTarget.classList.remove("is-invalid")
        } else {
          this.submitTarget.disabled = true
          this.fieldTarget.classList.add("is-invalid")
          const modal = new bootstrap.Modal(document.getElementById("emailTakenModal"))
          modal.show()
        }
      })
  }

  useDifferentEmail() {
    bootstrap.Modal.getInstance(document.getElementById("emailTakenModal")).hide()
    this.fieldTarget.value = ""
    this.fieldTarget.focus()
    this.submitTarget.disabled = false
    this.fieldTarget.classList.remove("is-invalid")
  }
}
