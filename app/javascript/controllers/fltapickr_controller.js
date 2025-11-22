import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";

// Connects to data-controller="fltapickr"
export default class extends Controller {
  static targets = ["date", "time"]

  connect() {
    if (this.hasDateTarget) {
      flatpickr(this.dateTarget, {
        altInput: true,
        dateFormat: "Y-m-d",
        minDate: "2025-11-20"
      })
    }

    if (this.hasTimeTarget) {
      flatpickr(this.timeTarget, {
        enableTime: true,
        noCalendar: true,
        dateFormat: "H:i"
      })
    }
  }
}
