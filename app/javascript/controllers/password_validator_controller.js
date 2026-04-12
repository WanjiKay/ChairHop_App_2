import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "confirmation", "reqLength", "reqNumber", "reqSpecial", "reqMatch"]

  validate() {
    const val = this.passwordTarget.value
    this.reqLengthTarget.classList.toggle('req-met', val.length >= 8)
    this.reqNumberTarget.classList.toggle('req-met', /[0-9]/.test(val))
    this.reqSpecialTarget.classList.toggle('req-met', /[!@#$%^&*()\-_=+\[\]{};':"\\|,.<>\/?]/.test(val))
    this.validateMatch()
  }

  validateMatch() {
    const matches = this.passwordTarget.value === this.confirmationTarget.value && this.confirmationTarget.value.length > 0
    this.reqMatchTarget.classList.toggle('req-met', matches)
  }
}
