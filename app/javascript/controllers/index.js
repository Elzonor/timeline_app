import { application } from "./application"

// Importa controller
import EventFormController from "./event_form_controller"
import DeleteConfirmationController from "./delete_confirmation_controller"

// Registra controller
application.register("event-form", EventFormController)
application.register("delete-confirmation", DeleteConfirmationController)

export function registerControllers() {
  // Funzione vuota, i controller sono già registrati
}