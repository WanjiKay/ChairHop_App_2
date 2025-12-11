// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SearchToggleController from "./search_toggle_controller"
import ResetFormController from "./reset_form_controller"
import ImageUploadController from "./image_upload_controller"


eagerLoadControllersFrom("controllers", application)
application.register("search-toggle", SearchToggleController)
application.register("reset-form", ResetFormController)
application.register("image-upload", ImageUploadController)
