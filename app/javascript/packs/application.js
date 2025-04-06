document.addEventListener('turbo:load', function() {
  // Calcola la posizione della data corrente per gli eventi ibridi
  const hybridEvents = document.querySelectorAll('.event-line.hybrid');
  const currentDate = new Date();
  
  hybridEvents.forEach(event => {
    const timeUnit = event.closest('.time-unit');
    if (!timeUnit) return;
    
    const timeUnitDate = new Date(timeUnit.dataset.date);
    const timeUnitWidth = timeUnit.offsetWidth;
    
    // Calcola la posizione relativa della data corrente all'interno della time-unit
    const timeUnitStart = timeUnitDate;
    const timeUnitEnd = new Date(timeUnitStart);
    timeUnitEnd.setDate(timeUnitEnd.getDate() + 1); // Aggiungi un giorno per time-unit giornaliere
    
    const totalTime = timeUnitEnd - timeUnitStart;
    const currentTime = currentDate - timeUnitStart;
    const position = (currentTime / totalTime) * 100;
    
    // Imposta la posizione come variabile CSS
    event.style.setProperty('--current-date-position', `${position}%`);
  });
}); 