import { application } from "./application"

// Importa controller
import EventFormController from "./event_form_controller"

// Registra controller
application.register("event-form", EventFormController)

export function registerControllers() {
  // Funzione vuota, i controller sono già registrati
} 