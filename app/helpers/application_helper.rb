module ApplicationHelper
  # Restituisce il titolo completo della pagina in base al contesto
  def page_title
    base_title = "TIMELINEZ"
    
    # Pagina principale (index delle timeline)
    return base_title if controller_name == 'timelines' && action_name == 'index'
    
    # Pagina di visualizzazione di una timeline
    if controller_name == 'timelines' && action_name == 'show' && @timeline.present?
      view_type = @timeline.preferred_view_type
      return "#{@timeline.name} - #{view_type.capitalize}"
    end
    
    # Pagina di modifica di una timeline
    if controller_name == 'timelines' && action_name == 'edit' && @timeline.present?
      return @timeline.name
    end
    
    # Pagina di modifica di un evento
    if controller_path == 'timelines/events' && action_name == 'edit' && @event.present? && @timeline.present?
      return "#{@event.name} - #{@timeline.name}"
    end
    
    # Default per altre pagine
    return base_title
  end

  def format_event_dates(event)
    return unless event.start_date
    
    if event.event_duration == '1-day'
      content_tag(:span, "— #{l(event.start_date, format: '%d %b')}", class: 'font-normal')
    else
      duration_text = DurationFormatter.format_duration(event.duration)
      
      if event.event_type == 'open'
        content_tag(:span, "— #{l(event.start_date, format: '%d %b')} - ... (#{duration_text})", class: 'font-normal')
      else
        content_tag(:span, "— #{l(event.start_date, format: '%d %b')}-#{l(event.end_date, format: '%d %b')} (#{duration_text})", class: 'font-normal')
      end
    end
  end
end
