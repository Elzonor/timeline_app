module DurationCalculator
  def calculate_duration(start_date, end_date, events = nil)
    end_date_to_use = (end_date || Date.current).to_date
    start_date_to_use = start_date.to_date
    weeks = Set.new
    months = Set.new
    years = Set.new
    days = Set.new

    if events
      # Raccogliamo i giorni con eventi
      events.each do |event|
        event_end = (event.end_date || Date.current).to_date
        (event.start_date.to_date..event_end).each do |date|
          days << date
          # Aggiungiamo la settimana solo se contiene un evento
          weeks << date.beginning_of_week
          months << date.beginning_of_month
          years << date.beginning_of_year
        end
      end
    else
      # Se non abbiamo eventi, calcoliamo basandoci sulle date estreme
      current_date = start_date_to_use
      while current_date <= end_date_to_use
        days << current_date
        weeks << current_date.beginning_of_week
        months << current_date.beginning_of_month
        years << current_date.beginning_of_year
        current_date += 1.day
      end
    end

    # Calcoliamo tutte le settimane tra la data di inizio e fine per la visualizzazione
    all_weeks = Set.new
    current_week = start_date_to_use.beginning_of_week
    while current_week <= end_date_to_use.beginning_of_week
      all_weeks << current_week
      current_week += 1.week
    end

    {
      days: days.size,
      weeks: weeks.size,
      months: months.size,
      years: years.size,
      week_dates: all_weeks.to_a.sort,
      month_dates: months.to_a.sort
    }
  end
end 