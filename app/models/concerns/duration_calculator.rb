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
        years << date.beginning_of_year
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
    
    # Calcoliamo tutti i mesi tra la data di inizio e fine per la visualizzazione
    all_months = Set.new
    current_month = start_date_to_use.beginning_of_month
    while current_month <= end_date_to_use.beginning_of_month
      all_months << current_month
      current_month = (current_month + 1.month).beginning_of_month
    end
    
    # Calcoliamo tutti gli anni tra la data di inizio e fine per la visualizzazione
    all_years = Set.new
    current_year = start_date_to_use.beginning_of_year
    while current_year <= end_date_to_use.beginning_of_year
      all_years << current_year
      current_year = (current_year + 1.year).beginning_of_year
    end

    # Calcoliamo tutti i giorni tra la data di inizio e fine per la visualizzazione
    all_days = Set.new
    current_day = start_date_to_use
    while current_day <= end_date_to_use
      all_days << current_day
      current_day += 1.day
    end

    {
      days: days.size,
      weeks: weeks.size,
      months: months.size,
      years: years.size,
      total_years: calculate_total_years(start_date_to_use, end_date_to_use),
      day_dates: all_days.to_a.sort,
      week_dates: all_weeks.to_a.sort,
      month_dates: all_months.to_a.sort,
      year_dates: all_years.to_a.sort
    }
  end

  private

  def calculate_total_years(start_date, end_date)
    # Calcoliamo gli anni totali contando gli anni distinti attraversati
    # Se la timeline va da settembre 2023 a febbraio 2025, deve contare 3 anni (2023, 2024, 2025)
    start_date.year.upto(end_date.year).count
  end
end 