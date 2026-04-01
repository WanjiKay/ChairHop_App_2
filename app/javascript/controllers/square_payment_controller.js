import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cardContainer", "statusMessage", "cardButton", "nonceField"]
  static values = {
    applicationId: String,
    locationId:    String,
    depositLabel:  String,
    bypassMode:    Boolean
  }

  async connect() {
    if (this.bypassModeValue) {
      this.cardContainerTarget.innerHTML =
        '<div class="alert alert-warning mb-0">' +
        '<strong>⚠️ Dev Bypass Mode</strong> — Square payment skipped. ' +
        'A fake nonce will be submitted.' +
        '</div>'
      return
    }

    if (!this.applicationIdValue || !this.locationIdValue) {
      this.showError('Payment configuration error. Please contact support.')
      return
    }

    try {
      const payments = Square.payments(this.applicationIdValue, this.locationIdValue)
      this.card = await payments.card()
      await this.card.attach(this.cardContainerTarget)
    } catch (initError) {
      console.error('Square Payments initialization error:', initError)
      this.showError('Payment system unavailable. Please try again later.')
    }
  }

  async submit(event) {
    event.preventDefault()

    if (this.bypassModeValue) {
      this.nonceFieldTarget.value = 'cnon:DEVELOPMENT_BYPASS_TOKEN'
      this.element.submit()
      return
    }

    this.hideError()
    this.cardButtonTarget.disabled = true
    this.cardButtonTarget.textContent = 'Processing…'

    try {
      const result = await this.card.tokenize()

      if (result.status === 'OK') {
        this.nonceFieldTarget.value = result.token
        this.element.submit()
      } else {
        const errorMessage = result.errors
          ? result.errors.map(err => err.message).join(', ')
          : 'Payment failed. Please try again.'
        this.showError(errorMessage)
        this.resetButton()
      }
    } catch (tokenizeError) {
      console.error('Tokenization error:', tokenizeError)
      this.showError('Payment error. Please try again or contact support.')
      this.resetButton()
    }
  }

  showError(msg) {
    this.statusMessageTarget.textContent = msg
    this.statusMessageTarget.style.display = 'block'
  }

  hideError() {
    this.statusMessageTarget.style.display = 'none'
  }

  resetButton() {
    this.cardButtonTarget.disabled = false
    this.cardButtonTarget.textContent = this.depositLabelValue
  }
}
