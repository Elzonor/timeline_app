import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "singleDayRadio", 
    "multiDayRadio",
    "dateFields",
    "singleDayContainer",
    "multiDayContainer",
    "startDate",
    "endDate",
    "submitButton",
    "deleteButton"
  ]

  static values = {
    durationType: { type: String, default: "single" },
    currentDurationType: String
  }

  connect() {
    // Inizializzazione del form
    this.currentDurationTypeValue = this.element.querySelector("#current_duration_type").value
    this.durationTypeValue = this.singleDayRadioTarget.checked ? "single" : "multi"
    this.updateFormState()
  }

  // Gestione cambio tipo durata
  toggleDurationType(event) {
    this.durationTypeValue = event.currentTarget.value === "1-day" ? "single" : "multi"
    this.updateFormState()
  }

  // Aggiornamento stato del form
  updateFormState() {
    this.moveDateFields()
    this.toggleEndDateVisibility()
    this.validateDates()
  }

  // Spostamento dei campi data
  moveDateFields() {
    const targetContainer = this.durationTypeValue === "single" 
      ? this.singleDayContainerTarget 
      : this.multiDayContainerTarget

    if (this.dateFieldsTarget.parentElement !== targetContainer) {
      targetContainer.appendChild(this.dateFieldsTarget)
    }
  }

  // Gestione visibilità campo end_date
  toggleEndDateVisibility() {
    const endDateField = this.endDateTarget.closest('.date-field')
    if (this.durationTypeValue === "single") {
      endDateField.classList.add("hidden")
    } else {
      endDateField.classList.remove("hidden")
    }
  }

  // Validazione date
  validateDates() {
    const startDate = this.startDateTarget.value
    const endDate = this.endDateTarget.value

    if (this.durationTypeValue === "single") {
      this.endDateTarget.value = startDate
    } else {
      // Se stiamo passando da single a multi e le date sono uguali, resettiamo end_date
      if (this.currentDurationTypeValue === "1-day" && endDate === startDate) {
        this.endDateTarget.value = ""
      }
    }
  }

  // Gestione submit form
  submitForm(event) {
    if (this.durationTypeValue === "single") {
      this.endDateTarget.value = this.startDateTarget.value
    }
  }

  // Gestione eliminazione evento
  deleteEvent(event) {
    if (!confirm("Sei sicuro di voler eliminare questo evento?")) {
      event.preventDefault()
    }
  }
} 