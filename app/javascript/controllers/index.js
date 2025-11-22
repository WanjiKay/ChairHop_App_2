// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SearchToggleController from "./search_toggle_controller"


eagerLoadControllersFrom("controllers", application)
application.register("search-toggle", SearchToggleController)
