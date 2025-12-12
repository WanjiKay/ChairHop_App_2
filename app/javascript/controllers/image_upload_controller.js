import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["area", "input", "previewContainer", "previewImage", "removeButton"]

  connect() {
    this.boundHandleDragOver = this.handleDragOver.bind(this)
    this.boundHandleDragLeave = this.handleDragLeave.bind(this)
    this.boundHandleDrop = this.handleDrop.bind(this)

    this.areaTarget.addEventListener('dragover', this.boundHandleDragOver)
    this.areaTarget.addEventListener('dragleave', this.boundHandleDragLeave)
    this.areaTarget.addEventListener('drop', this.boundHandleDrop)
  }

  disconnect() {
    this.areaTarget.removeEventListener('dragover', this.boundHandleDragOver)
    this.areaTarget.removeEventListener('dragleave', this.boundHandleDragLeave)
    this.areaTarget.removeEventListener('drop', this.boundHandleDrop)
  }

  openFileDialog(event) {
    if (!this.hasRemoveButtonTarget ||
        (event.target !== this.removeButtonTarget && !this.removeButtonTarget.contains(event.target))) {
      this.inputTarget.click()
    }
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file && file.type.startsWith('image/')) {
      this.showPreview(file)
    }
  }

  removePreview(event) {
    event.stopPropagation()
    this.inputTarget.value = ''
    this.previewContainerTarget.classList.add('d-none')
    this.previewImageTarget.src = ''
  }

  handleDragOver(event) {
    event.preventDefault()
    this.areaTarget.classList.add('drag-over')
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.areaTarget.classList.remove('drag-over')
  }

  handleDrop(event) {
    event.preventDefault()
    this.areaTarget.classList.remove('drag-over')

    const files = event.dataTransfer.files
    if (files.length > 0 && files[0].type.startsWith('image/')) {
      this.inputTarget.files = files
      this.showPreview(files[0])
    }
  }

  showPreview(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.previewContainerTarget.classList.remove('d-none')
    }
    reader.readAsDataURL(file)
  }
}
