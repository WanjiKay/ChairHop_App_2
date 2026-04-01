import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = [
    "datePicker", "timeSection", "timeSlots",
    "selectedTime", "selectedBlockId", "selectedLocationId",
    "modalDateTime", "modalLocation",
    "modalServiceList", "addOnSection", "addOnList",
    "modalSummary", "summaryTime", "summaryService",
    "summaryAddOnsRow", "summaryAddOns", "summaryDeposit",
    "form", "formTime", "formBlockId", "formServiceName",
    "formAddOnIds", "submitBtn"
  ]
  static values = {
    stylistId: String,
    slotsUrl: String
  }

  connect() {
    const dates = window.CHAIRHOP_AVAILABLE_DATES || []
    this.availableDates = new Set(dates)

    // Initialize Flatpickr with only available dates enabled
    if (typeof flatpickr !== 'undefined') {
      this.flatpickrInstance = flatpickr(this.datePickerTarget, {
        enable: dates,
        dateFormat: "Y-m-d",
        minDate: "today",
        disableMobile: false,
        onChange: (_selectedDates, dateStr) => {
          this.datePickerTarget.value = dateStr
          this.dateChanged()
        }
      })
    }
  }

  disconnect() {
    if (this.flatpickrInstance) {
      this.flatpickrInstance.destroy()
      this.flatpickrInstance = null
    }
  }

  async dateChanged() {
    const date = this.datePickerTarget.value
    if (!date) return

    // Fetch available slots for this date
    this.timeSlotsTarget.innerHTML =
      '<div class="text-muted small">Loading available times...</div>'
    this.timeSectionTarget.style.display = 'block'

    try {
      const url = `${this.slotsUrlValue}?stylist_id=${this.stylistIdValue}&date=${date}`
      const response = await fetch(url, {
        headers: { Accept: 'application/json' }
      })
      const data = await response.json()
      this.timeSlotsTarget.innerHTML = ''

      if (data.slots.length === 0) {
        this.timeSlotsTarget.innerHTML =
          '<p class="text-muted small">No available times for this date.</p>'
        return
      }

      data.slots.forEach(slot => {
        const btn = document.createElement('button')
        btn.type = 'button'
        btn.className = 'btn btn-outline-primary btn-sm'
        btn.textContent = slot.label
        btn.dataset.time = slot.time
        btn.dataset.blockId = slot.block_id
        btn.dataset.locationId = slot.location_id
        btn.dataset.location = slot.location || ''
        btn.dataset.action = 'click->booking-form#selectSlot'
        this.timeSlotsTarget.appendChild(btn)
      })
    } catch(e) {
      this.timeSlotsTarget.innerHTML =
        '<p class="text-danger small">Could not load times. Please try again.</p>'
    }
  }

  selectSlot(event) {
    // Highlight selected slot
    this.timeSlotsTarget.querySelectorAll('button').forEach(b => {
      b.classList.remove('btn-primary')
      b.classList.add('btn-outline-primary')
    })
    event.currentTarget.classList.remove('btn-outline-primary')
    event.currentTarget.classList.add('btn-primary')

    const btn = event.currentTarget
    this.selectedTimeTarget.value = btn.dataset.time
    this.selectedBlockIdTarget.value = btn.dataset.blockId
    this.selectedLocationIdTarget.value = btn.dataset.locationId

    // Update modal header info
    const timeLabel = new Date(btn.dataset.time).toLocaleString('en-US', {
      weekday: 'short', month: 'short', day: 'numeric',
      hour: 'numeric', minute: '2-digit', hour12: true, timeZone: 'UTC'
    })
    this.modalDateTimeTarget.textContent = timeLabel
    this.modalLocationTarget.textContent = btn.dataset.location
      ? '· ' + btn.dataset.location : ''

    // Wire form fields
    this.formTimeTarget.value = btn.dataset.time
    this.formBlockIdTarget.value = btn.dataset.blockId

    // Reset modal state
    this.modalServiceListTarget.querySelectorAll('.service-option').forEach(c => {
      c.classList.remove('border-primary', 'bg-light')
    })
    this.addOnSectionTarget.style.display = 'none'
    this.modalSummaryTarget.style.display = 'none'
    this.submitBtnTarget.style.display = 'none'
    this.selectedServiceData = null
    this.selectedAddOns = []

    // Open the modal
    const modal = document.getElementById('serviceSelectionModal')
    if (modal) Modal.getOrCreateInstance(modal).show()
  }

  selectService(event) {
    const card = event.currentTarget
    const name = card.dataset.serviceName
    const price = parseFloat(card.dataset.servicePrice)

    // Highlight selected
    this.modalServiceListTarget.querySelectorAll('.service-option').forEach(c => {
      c.classList.remove('border-primary', 'bg-light')
    })
    card.classList.add('border-primary', 'bg-light')

    this.formServiceNameTarget.value = name
    this.selectedServiceData = { name, price }

    // Show add-ons if any exist
    const addOns = this.addOnListTarget.querySelectorAll('.addon-option')
    if (addOns.length > 0) {
      this.addOnSectionTarget.style.display = 'block'
    }

    // Reset add-on selections
    this.addOnListTarget.querySelectorAll('.addon-checkbox').forEach(cb => {
      cb.checked = false
      cb.closest('.addon-option').classList.remove('border-primary', 'bg-light')
    })
    this.selectedAddOns = []

    this._updateSummary()
  }

  toggleAddon(event) {
    const card = event.currentTarget
    const checkbox = card.querySelector('.addon-checkbox')
    checkbox.checked = !checkbox.checked

    if (checkbox.checked) {
      card.classList.add('border-primary', 'bg-light')
      this.selectedAddOns = this.selectedAddOns || []
      this.selectedAddOns.push({
        id: card.dataset.addonId,
        name: card.dataset.addonName,
        price: parseFloat(card.dataset.addonPrice)
      })
    } else {
      card.classList.remove('border-primary', 'bg-light')
      this.selectedAddOns = (this.selectedAddOns || [])
        .filter(a => a.id !== card.dataset.addonId)
    }

    this._updateSummary()
  }

  _updateSummary() {
    if (!this.selectedServiceData) return

    const addOnsTotal = (this.selectedAddOns || [])
      .reduce((sum, a) => sum + a.price, 0)
    const total = this.selectedServiceData.price + addOnsTotal
    const deposit = (total * 0.5).toFixed(2)

    const timeVal = this.selectedTimeTarget.value
    const timeLabel = timeVal ? new Date(timeVal).toLocaleString('en-US', {
      weekday: 'short', month: 'short', day: 'numeric',
      hour: 'numeric', minute: '2-digit', hour12: true, timeZone: 'UTC'
    }) : ''

    this.summaryTimeTarget.textContent = timeLabel
    this.summaryServiceTarget.textContent =
      `${this.selectedServiceData.name} ($${this.selectedServiceData.price.toFixed(2)})`

    if (this.selectedAddOns?.length > 0) {
      this.summaryAddOnsRowTarget.style.display = ''
      this.summaryAddOnsTarget.textContent =
        this.selectedAddOns.map(a => `${a.name} (+$${a.price.toFixed(2)})`).join(', ')
    } else {
      this.summaryAddOnsRowTarget.style.display = 'none'
    }

    this.summaryDepositTarget.textContent = `$${deposit}`

    // Update add-on hidden field
    const addOnIds = (this.selectedAddOns || []).map(a => a.id).join(',')
    this.formAddOnIdsTarget.value = addOnIds

    this.modalSummaryTarget.style.display = 'block'
    this.submitBtnTarget.style.display = 'inline-block'
  }
}
