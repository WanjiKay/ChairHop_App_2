import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "error", "count", "uploadBtn"]
  static values = {
    maxSizeMb: { type: Number, default: 10 },
    maxFiles:  { type: Number, default: 0 },   // 0 = no limit
    uploadUrl: { type: String, default: "" },
    csrf:      { type: String, default: "" }
  }

  connect() {
    this._dt = new DataTransfer()
  }

  preview() {
    const incoming = Array.from(this.inputTarget.files)
    this.errorTarget.textContent = ""

    const oversized = incoming.filter(f => f.size > this.maxSizeMbValue * 1024 * 1024)
    if (oversized.length > 0) {
      this.errorTarget.textContent =
        `${oversized.length} photo(s) exceed the ${this.maxSizeMbValue}MB limit: ` +
        oversized.map(f => f.name).join(", ") +
        ". Please compress them before uploading."
      this.inputTarget.value = ""
      return
    }

    // Accumulate new files (skip exact-name duplicates already queued)
    const existing = new Set(Array.from(this._dt.files).map(f => f.name))
    for (const file of incoming) {
      if (!existing.has(file.name)) this._dt.items.add(file)
    }

    // Enforce maxFiles cap
    if (this.maxFilesValue > 0 && this._dt.files.length > this.maxFilesValue) {
      this.errorTarget.textContent =
        `You can only upload up to ${this.maxFilesValue} photo(s) at a time.`
      // Trim extras from the end
      while (this._dt.files.length > this.maxFilesValue) {
        this._dt.items.remove(this._dt.files.length - 1)
      }
    }

    this.inputTarget.files = this._dt.files

    if (this.hasCountTarget) {
      this.countTarget.textContent =
        this._dt.files.length
          ? `${this._dt.files.length} photo(s) selected`
          : ""
    }

    this._renderPreviews()
    this._toggleUploadBtn()
  }

  removeFile(event) {
    const name = event.currentTarget.dataset.filename
    const updated = new DataTransfer()
    for (const f of Array.from(this._dt.files)) {
      if (f.name !== name) updated.items.add(f)
    }
    this._dt = updated
    this.inputTarget.files = this._dt.files

    if (this.hasCountTarget) {
      this.countTarget.textContent =
        this._dt.files.length
          ? `${this._dt.files.length} photo(s) selected`
          : ""
    }

    this._renderPreviews()
    this._toggleUploadBtn()
  }

  _renderPreviews() {
    this.previewTarget.innerHTML = ""

    Array.from(this._dt.files).forEach(file => {
      const reader = new FileReader()
      reader.onload = (e) => {
        const wrapper = document.createElement("div")
        wrapper.style.cssText = "display:inline-block; margin:4px; position:relative;"

        const img = document.createElement("img")
        img.src = e.target.result
        img.style.cssText = "height:80px; width:80px; object-fit:cover; border-radius:6px; display:block;"
        img.alt = file.name

        const removeBtn = document.createElement("button")
        removeBtn.type = "button"
        removeBtn.dataset.filename = file.name
        removeBtn.dataset.action = "click->photo-preview#removeFile"
        removeBtn.style.cssText =
          "position:absolute; top:2px; right:2px; " +
          "width:18px; height:18px; border-radius:50%; " +
          "background:rgba(220,53,69,0.85); color:#fff; border:none; " +
          "font-size:10px; line-height:1; cursor:pointer; " +
          "display:flex; align-items:center; justify-content:center;"
        removeBtn.innerHTML = "&times;"
        removeBtn.title = "Remove"

        const label = document.createElement("div")
        label.style.cssText =
          "font-size:10px; text-align:center; color:#6c757d; " +
          "max-width:80px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
        label.textContent = (file.size / 1024 / 1024).toFixed(1) + "MB"

        wrapper.appendChild(img)
        wrapper.appendChild(removeBtn)
        wrapper.appendChild(label)
        this.previewTarget.appendChild(wrapper)
      }
      reader.readAsDataURL(file)
    })
  }

  _toggleUploadBtn() {
    if (this.hasUploadBtnTarget) {
      this.uploadBtnTarget.style.display =
        this._dt.files.length > 0 ? 'inline-block' : 'none'
    }
  }

  async uploadPhotos() {
    if (!this.uploadUrlValue || this._dt.files.length === 0) return
    const btn = this.uploadBtnTarget
    btn.disabled = true
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i> Uploading...'

    const formData = new FormData()
    Array.from(this._dt.files).forEach(f => {
      formData.append('user[portfolio_photos][]', f)
    })

    try {
      const response = await fetch(this.uploadUrlValue, {
        method: 'POST',
        headers: { 'X-CSRF-Token': this.csrfValue },
        body: formData
      })
      const data = await response.json()

      if (data.success) {
        this.errorTarget.textContent = ''
        this.countTarget.textContent = data.message
        this.countTarget.className = 'text-success small mb-2'
        this.previewTarget.innerHTML = ''
        this._dt = new DataTransfer()
        this.inputTarget.value = ''
        btn.style.display = 'none'
        btn.disabled = false
        btn.innerHTML = '<i class="fas fa-upload me-1"></i> Upload Photos'
        // Reload to show new photos in the existing grid
        setTimeout(() => window.location.reload(), 1200)
      } else {
        this.errorTarget.textContent = data.error
        btn.disabled = false
        btn.innerHTML = '<i class="fas fa-upload me-1"></i> Upload Photos'
      }
    } catch(e) {
      this.errorTarget.textContent = 'Upload failed. Please try again.'
      btn.disabled = false
      btn.innerHTML = '<i class="fas fa-upload me-1"></i> Upload Photos'
    }
  }
}
