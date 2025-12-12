import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  static targets = ["filters", "date", "time"];

  connect() {
    // Flatpickr se inicializa solo cuando el form se hace visible (en toggle)
  }

  toggle() {
    this.filtersTarget.classList.toggle("d-none");

    // Initialize flatpickr only when the form becomes visible
    if (!this.filtersTarget.classList.contains("d-none")) {
      this.initFlatpickr();
    }
  }

  initFlatpickr() {
    if (this.dateTarget && !this.dateTarget._flatpickr) {
      flatpickr(this.dateTarget, { dateFormat: "Y-m-d" });
    }
    if (this.timeTarget && !this.timeTarget._flatpickr) {
      flatpickr(this.timeTarget, { enableTime: true, noCalendar: true, dateFormat: "H:i" });
    }
  }
}
