import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "prev", "next"]
  static values  = {
    perPage: { type: Number, default: 3 },
    page:    { type: Number, default: 0 }
  }

  connect() { this.render() }

  prev() {
    if (this.pageValue > 0) {
      this.pageValue--
      this.render()
    }
  }

  next() {
    if (this.pageValue < this.maxPage) {
      this.pageValue++
      this.render()
    }
  }

  get maxPage() {
    return Math.ceil(this.slideTargets.length / this.perPageValue) - 1
  }

  render() {
    const start = this.pageValue * this.perPageValue
    const end   = start + this.perPageValue

    this.slideTargets.forEach((el, i) => {
      el.style.display = (i >= start && i < end) ? "" : "none"
    })

    this.prevTarget.disabled = this.pageValue === 0
    this.nextTarget.disabled = this.pageValue >= this.maxPage
  }
}
