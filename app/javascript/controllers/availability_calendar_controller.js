import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = [
    "calendar",
    "availabilityModal", "blockTime", "blockLocation", "editBlockBtn", "deleteBlockBtn",
    "appointmentModal", "appointmentStatusBadge", "appointmentCustomer", "appointmentService",
    "appointmentTime", "appointmentLocation", "viewAppointmentBtn"
  ]
  static values = {
    events:        Array,
    blockBasePath: String
  }

  connect() {
    this.calendarInstance = null
    this.resizeTimer      = null
    this._boundResize     = this.handleResize.bind(this)

    if (typeof FullCalendar === 'undefined') {
      console.error('FullCalendar not loaded')
      return
    }

    this.initCalendar()
    window.addEventListener('resize', this._boundResize)
  }

  disconnect() {
    window.removeEventListener('resize', this._boundResize)
    clearTimeout(this.resizeTimer)
    if (this.calendarInstance) {
      this.calendarInstance.destroy()
      this.calendarInstance = null
    }
  }

  initCalendar() {
    if (this.calendarInstance) {
      this.calendarInstance.destroy()
    }

    const isMobile = window.innerWidth < 768

    this.calendarInstance = new FullCalendar.Calendar(this.calendarTarget, {
      initialView: isMobile ? 'timeGridTwoDay' : 'timeGridWeek',
      headerToolbar: {
        left:   'prev,next today',
        center: 'title',
        right:  isMobile ? 'timeGridTwoDay,timeGridDay' : 'timeGridWeek,timeGridDay'
      },
      views: {
        timeGridTwoDay: {
          type:       'timeGrid',
          duration:   { days: 2 },
          buttonText: '2 days'
        }
      },
      timeZone:        'UTC',
      slotDuration:    '01:00:00',
      slotMinTime:     '06:00:00',
      slotMaxTime:     '22:00:00',
      firstDay:        0,
      height:          650,
      nowIndicator:    true,
      allDaySlot:      false,
      scrollTime:      '08:00:00',
      slotLabelFormat: { hour: 'numeric', minute: '2-digit', hour12: true },

      events: this.eventsValue,

      eventClassNames: (arg) => {
        const props = arg.event.extendedProps
        if (props.type === 'availability') return ['availability-block']
        if (props.status === 'booked')     return ['booked-appointment']
        if (props.status === 'pending')    return ['pending-appointment']
        return []
      },

      eventClick: (info) => {
        const props = info.event.extendedProps
        if (props.type === 'availability') {
          this.showAvailabilityModal(info.event)
        } else {
          this.showAppointmentModal(info.event)
        }
      }
    })

    this.calendarInstance.render()
  }

  handleResize() {
    clearTimeout(this.resizeTimer)
    this.resizeTimer = setTimeout(() => {
      if (!this.calendarInstance) return
      const nowMobile  = window.innerWidth < 768
      const currentView = this.calendarInstance.view.type
      if (nowMobile && currentView === 'timeGridWeek') {
        this.calendarInstance.changeView('timeGridTwoDay')
      } else if (!nowMobile && currentView === 'timeGridTwoDay') {
        this.calendarInstance.changeView('timeGridWeek')
      }
    }, 250)
  }

  showAvailabilityModal(event) {
    const blockId  = event.extendedProps.blockId
    const location = event.extendedProps.location || 'Unknown'
    const opts     = { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit', hour12: true, timeZone: 'UTC' }
    const timeOpts = { hour: 'numeric', minute: '2-digit', hour12: true, timeZone: 'UTC' }
    const timeStr  = new Date(event.start).toLocaleString('en-US', opts) +
                     ' \u2013 ' +
                     new Date(event.end).toLocaleTimeString('en-US', timeOpts)

    this.blockTimeTarget.textContent     = timeStr
    this.blockLocationTarget.textContent = location
    this.editBlockBtnTarget.href = `${this.blockBasePathValue}/${blockId}/edit`

    this.deleteBlockBtnTarget.onclick = () => {
      if (confirm(`Delete this availability block?\n\n${timeStr}\n${location}`)) {
        fetch(`${this.blockBasePathValue}/${blockId}`, {
          method:  'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
            'Accept':       'application/json'
          }
        }).then(res => { if (res.ok) window.location.reload() })
      }
    }

    Modal.getOrCreateInstance(this.availabilityModalTarget).show()
  }

  showAppointmentModal(event) {
    const props     = event.extendedProps
    const isPending = props.status === 'pending'
    const timeStr   = new Date(event.start).toLocaleString('en-US', {
      weekday: 'short', month: 'short', day: 'numeric',
      hour: 'numeric', minute: '2-digit', hour12: true, timeZone: 'UTC'
    })

    const badge      = this.appointmentStatusBadgeTarget
    badge.textContent = isPending ? 'Pending Your Response' : 'Confirmed'
    badge.className   = 'badge fs-6 mb-3 ' + (isPending ? 'bg-warning text-dark' : 'bg-primary')

    this.appointmentCustomerTarget.textContent  = props.customerName || 'Unknown'
    this.appointmentServiceTarget.textContent   = props.serviceName  || 'Appointment'
    this.appointmentTimeTarget.textContent      = timeStr
    this.appointmentLocationTarget.textContent  = props.location     || 'Not specified'
    this.viewAppointmentBtnTarget.href          = `/appointments/${props.appointmentId}`

    Modal.getOrCreateInstance(this.appointmentModalTarget).show()
  }
}
