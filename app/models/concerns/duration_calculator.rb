module DurationCalculator
  def calculate_duration(start_date, end_date)
    end_date_to_use = end_date || Date.current
    weeks = Set.new
    months = Set.new
    current_date = start_date

    while current_date <= end_date_to_use
      weeks << current_date.beginning_of_week
      months << current_date.beginning_of_month
      current_date += 1.day
    end

    {
      days: (end_date_to_use.to_date - start_date.to_date).to_i,
      weeks: weeks.size,
      months: months.size
    }
  end
end 