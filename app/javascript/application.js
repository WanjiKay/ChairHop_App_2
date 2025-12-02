import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import SearchToggleController from "search_toggle_controller"

const application = Application.start()
application.register("search-toggle", SearchToggleController)
