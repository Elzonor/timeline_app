module DurationCalculator
  def calculate_duration(start_date, end_date, events = nil)
    end_date_to_use = (end_date || Date.current).to_date
    weeks = Set.new
    months = Set.new
    days = Set.new

    if events
      events.each do |event|
        event_end = (event.end_date || Date.current).to_date
        (event.start_date.to_date..event_end).each do |date|
          days << date
          weeks << date.beginning_of_week
          months << date.beginning_of_month
        end
      end
    else
      # Se non abbiamo eventi, calcoliamo basandoci sulle date estreme
      current_date = start_date.to_date
      while current_date <= end_date_to_use
        days << current_date
        weeks << current_date.beginning_of_week
        months << current_date.beginning_of_month
        current_date += 1.day
      end
    end

    {
      days: days.size,
      weeks: weeks.size,
      months: months.size,
      week_dates: weeks.to_a.sort,
      month_dates: months.to_a.sort
    }
  end
end 