import { Controller } from "@hotwired/stimulus"

// Gestisce lo spostamento dei campi data tra i contenitori single-day e multi-day
export default class extends Controller {
  static targets = ["dateFieldsContainer", "singleDayContainer", "multiDayContainer", "singleDayRadio", "multiDayRadio"]

  connect() {
    // Inizializzazione all'avvio del controller
    this.updateFieldsPosition()
  }

  // Chiamata quando cambia la selezione dei radio button
  toggleDateFields() {
    this.updateFieldsPosition()
  }

  // Aggiorna la posizione dei campi data in base al radio button selezionato
  updateFieldsPosition() {
    if (!this.hasDateFieldsContainerTarget) return
    
    // Verifica quale radio button è selezionato
    if (this.hasSingleDayRadioTarget && this.singleDayRadioTarget.checked) {
      this.moveDateFields(this.singleDayContainerTarget)
    } else if (this.hasMultiDayRadioTarget && this.multiDayRadioTarget.checked) {
      this.moveDateFields(this.multiDayContainerTarget)
    }
  }

  // Sposta i campi data nel contenitore specificato
  moveDateFields(targetContainer) {
    if (this.dateFieldsContainerTarget.parentElement !== targetContainer) {
      targetContainer.appendChild(this.dateFieldsContainerTarget)
    }
  }
} 