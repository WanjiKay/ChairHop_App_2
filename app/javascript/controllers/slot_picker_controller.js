import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateSelect", "timeSelect"]
  static values  = { slots: Array }

  connect() {
    const slotsByDate = {}
    this.slotsValue.forEach(slot => {
      const dateKey = slot.time.split('T')[0]
      if (!slotsByDate[dateKey]) slotsByDate[dateKey] = []
      slotsByDate[dateKey].push(slot)
    })
    this._slotsByDate = slotsByDate

    Object.keys(slotsByDate).sort().forEach(date => {
      const parts   = date.split('-').map(Number)
      const dateObj = new Date(parts[0], parts[1] - 1, parts[2])
      const option  = document.createElement('option')
      option.value       = date
      option.textContent = dateObj.toLocaleDateString('en-US', {
        weekday: 'short', month: 'short', day: 'numeric'
      })
      this.dateSelectTarget.appendChild(option)
    })
  }

  dateChanged() {
    const timeSelect = this.timeSelectTarget
    timeSelect.innerHTML = '<option value="">Choose a time...</option>'
    timeSelect.disabled  = false

    ;(this._slotsByDate[this.dateSelectTarget.value] || []).forEach(slot => {
      const option       = document.createElement('option')
      option.value       = slot.time
      option.textContent = slot.label
      timeSelect.appendChild(option)
    })
  }
}
