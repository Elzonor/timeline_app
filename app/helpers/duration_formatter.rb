module DurationFormatter
  DAYS_IN_WEEK = 7
  DAYS_IN_MONTH = 30.44 # media
  DAYS_IN_YEAR = 365.25 # considera anni bisestili

  def self.format_duration(total_days)
    return nil if total_days.nil?
    
    case total_days.to_i
    when 0..6
      format_days(total_days)
    when 7..29
      format_weeks(total_days)
    when 30..364
      format_months(total_days)
    else
      format_years(total_days)
    end
  end

  private

  def self.format_days(days)
    days == 1 ? "1 giorno" : "#{days} giorni"
  end

  def self.format_weeks(days)
    weeks = (days / DAYS_IN_WEEK).floor
    remaining_days = days % DAYS_IN_WEEK

    if remaining_days <= 2
      weeks == 1 ? "1 settimana" : "#{weeks} settimane"
    else
      week_text = weeks == 1 ? "1 settimana" : "#{weeks} settimane"
      day_text = remaining_days == 1 ? "1 giorno" : "#{remaining_days} giorni"
      "#{week_text} e #{day_text}"
    end
  end

  def self.format_months(days)
    months = (days / DAYS_IN_MONTH).floor
    remaining_days = (days % DAYS_IN_MONTH).round

    if remaining_days == 0
      months == 1 ? "1 mese" : "#{months} mesi"
    else
      month_text = months == 1 ? "1 mese" : "#{months} mesi"
      day_text = remaining_days == 1 ? "1 giorno" : "#{remaining_days} giorni"
      "#{month_text} e #{day_text}"
    end
  end

  def self.format_years(days)
    years = (days / DAYS_IN_YEAR).floor
    remaining_months = ((days % DAYS_IN_YEAR) / DAYS_IN_MONTH).floor

    if remaining_months < 2
      years == 1 ? "1 anno" : "#{years} anni"
    else
      year_text = years == 1 ? "1 anno" : "#{years} anni"
      month_text = remaining_months == 1 ? "1 mese" : "#{remaining_months} mesi"
      "#{year_text} e #{month_text}"
    end
  end
end 