import { Application } from "@hotwired/stimulus"
import SearchToggleController from "search_toggle_controller"

const application = Application.start()
application.register("search-toggle", SearchToggleController)
