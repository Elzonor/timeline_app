const EventDurationManager = {
  elements: {
    form: null,
    singleDayRadio: null,
    multiDayRadio: null,
    singleDayDate: null,
    multiDayStartDate: null,
    multiDayEndDate: null,
    submitButton: null,
    validationMessage: null,
    currentDurationType: null
  },

  state: {
    isDurationSingleDay: true,
    hasValidDates: false
  },

  init() {
    // Assicuriamoci che il DOM sia completamente caricato
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.initialize());
    } else {
      this.initialize();
    }
  },

  initialize() {
    this.bindElements();
    if (!this.elements.form) return; // Usciamo se non siamo in una pagina con il form
    this.createValidationMessage();
    this.bindEvents();
    this.setInitialState();
    this.render();
  },

  bindElements() {
    this.elements.form = document.querySelector('.events-form');
    if (!this.elements.form) return;
    
    this.elements.singleDayRadio = document.querySelector('#duration_type_single');
    this.elements.multiDayRadio = document.querySelector('#duration_type_multi');
    this.elements.singleDayDate = document.querySelector('.single-day-date');
    this.elements.multiDayStartDate = document.querySelector('.multi-day-start');
    this.elements.multiDayEndDate = document.querySelector('.multi-day-end');
    this.elements.submitButton = this.elements.form.querySelector('input[type="submit"]');
    this.elements.currentDurationType = document.querySelector('#current_duration_type');
  },

  createValidationMessage() {
    const validationDiv = document.createElement('div');
    validationDiv.className = 'validation-message';
    validationDiv.style.color = 'red';
    validationDiv.style.display = 'none';
    validationDiv.style.marginTop = '5px';
    this.elements.multiDayEndDate.parentElement.appendChild(validationDiv);
    this.elements.validationMessage = validationDiv;
  },

  bindEvents() {
    this.elements.singleDayRadio.addEventListener('change', () => this.handleDurationTypeChange(true));
    this.elements.multiDayRadio.addEventListener('change', () => this.handleDurationTypeChange(false));
    this.elements.singleDayDate.addEventListener('change', () => this.handleSingleDayDateChange());
    this.elements.multiDayStartDate.addEventListener('change', () => this.handleMultiDayStartDateChange());
    this.elements.multiDayEndDate.addEventListener('change', () => this.handleMultiDayEndDateChange());
    this.elements.form.addEventListener('submit', (e) => this.handleSubmit(e));
  },

  setInitialState() {
    // Determina il tipo di durata dal campo nascosto
    const durationType = this.elements.currentDurationType.value;
    this.state.isDurationSingleDay = durationType === '1-day';

    if (this.state.isDurationSingleDay) {
      // Se è un evento di un giorno, imposta la data nel campo single-day
      this.elements.singleDayRadio.checked = true;
      this.elements.singleDayDate.value = this.elements.multiDayStartDate.value;
      // Pulisci i campi multi-day
      this.elements.multiDayStartDate.value = '';
      this.elements.multiDayEndDate.value = '';
    } else {
      // Se è un evento multi-giorno, assicurati che il radio button corretto sia selezionato
      this.elements.multiDayRadio.checked = true;
      // Pulisci il campo single-day
      this.elements.singleDayDate.value = '';
    }
    
    this.validateDates();
  },

  validateDates() {
    if (this.state.isDurationSingleDay) {
      this.state.hasValidDates = !!this.elements.singleDayDate.value;
      this.elements.validationMessage.style.display = 'none';
    } else {
      const startDate = new Date(this.elements.multiDayStartDate.value);
      const endDate = new Date(this.elements.multiDayEndDate.value);
      
      if (!this.elements.multiDayStartDate.value || !this.elements.multiDayEndDate.value) {
        this.state.hasValidDates = false;
        this.elements.validationMessage.textContent = 'Entrambe le date sono richieste';
        this.elements.validationMessage.style.display = 'block';
      } else if (endDate <= startDate) {
        this.state.hasValidDates = false;
        this.elements.validationMessage.textContent = 'La data di fine deve essere successiva alla data di inizio';
        this.elements.validationMessage.style.display = 'block';
      } else {
        this.state.hasValidDates = true;
        this.elements.validationMessage.style.display = 'none';
      }
    }

    this.elements.submitButton.disabled = !this.state.hasValidDates;
  },

  render() {
    this.elements.singleDayDate.style.display = this.state.isDurationSingleDay ? 'block' : 'none';
    this.elements.multiDayStartDate.parentElement.parentElement.style.display = 
      this.state.isDurationSingleDay ? 'none' : 'flex';

    this.validateDates();
  },

  handleDurationTypeChange(isSingleDay) {
    this.state.isDurationSingleDay = isSingleDay;
    
    if (isSingleDay) {
      this.elements.multiDayStartDate.value = '';
      this.elements.multiDayEndDate.value = '';
    } else {
      this.elements.singleDayDate.value = '';
    }
    
    this.render();
  },

  handleSingleDayDateChange() {
    if (this.state.isDurationSingleDay) {
      this.elements.multiDayStartDate.value = '';
      this.elements.multiDayEndDate.value = '';
    }
    this.validateDates();
  },

  handleMultiDayStartDateChange() {
    if (!this.state.isDurationSingleDay) {
      this.elements.singleDayDate.value = '';
    }
    this.validateDates();
  },

  handleMultiDayEndDateChange() {
    if (!this.state.isDurationSingleDay) {
      this.elements.singleDayDate.value = '';
    }
    this.validateDates();
  },

  handleSubmit(e) {
    if (!this.state.hasValidDates) {
      e.preventDefault();
      return;
    }
  }
};

// Inizializzazione immediata
EventDurationManager.init(); 