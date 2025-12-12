import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "form", "messagesContainer"]

  connect() {
    requestAnimationFrame(() => {
      this.scrollToBottom()
    })
    this.resizeTextarea()
  }

  // Auto-resize textarea
  resizeTextarea() {
    if (!this.hasTextareaTarget) return
    const textarea = this.textareaTarget
    textarea.style.height = 'auto'
    textarea.style.height = textarea.scrollHeight + 'px'
  }

  // Input event para resize
  handleInput() {
    this.resizeTextarea()
  }

  // Enter para enviar (Shift+Enter para nueva línea)
  handleKeydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }

  // Botón de sugerencia rápida - pobla y envía automáticamente
  insertSuggestion(event) {
    const text = event.currentTarget.dataset.chatMessageText
    this.textareaTarget.value = text
    this.resizeTextarea()
    this.formTarget.requestSubmit()
  }

  // Auto-scroll al final
  scrollToBottom() {
    if (this.hasMessagesContainerTarget) {
      this.messagesContainerTarget.scrollTop = this.messagesContainerTarget.scrollHeight
    }
  }
}
