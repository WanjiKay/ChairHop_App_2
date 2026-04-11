import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "photoInput", "imagePreview", "previewImg", "textarea", "form"]

  connect() {
    this.scrollToBottom()

    this._boundStreamRender  = () => setTimeout(() => this.scrollToBottom(), 50)
    this._boundFrameLoad     = () => this.scrollToBottom()
    this._boundWindowLoad    = () => this.scrollToBottom()

    document.addEventListener('turbo:before-stream-render', this._boundStreamRender)
    document.addEventListener('turbo:frame-load',           this._boundFrameLoad)
    window.addEventListener('load',                         this._boundWindowLoad)
  }

  disconnect() {
    document.removeEventListener('turbo:before-stream-render', this._boundStreamRender)
    document.removeEventListener('turbo:frame-load',           this._boundFrameLoad)
    window.removeEventListener('load',                         this._boundWindowLoad)
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  photoChanged(event) {
    const file = event.target.files[0]
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      reader.onload = (e) => {
        this.previewImgTarget.src = e.target.result
        this.imagePreviewTarget.classList.remove('d-none')
      }
      reader.readAsDataURL(file)
    }
  }

  removeImage() {
    this.photoInputTarget.value = ''
    this.imagePreviewTarget.classList.add('d-none')
  }

  keydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.formTarget.submit()
    }
  }
}
