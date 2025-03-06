module ApplicationHelper
  # Restituisce il titolo completo della pagina in base al contesto
  def page_title
    base_title = "TIMELINEZ"
    
    # Pagina principale (index delle timeline)
    return base_title if controller_name == 'timelines' && action_name == 'index'
    
    # Pagina di visualizzazione di una timeline
    if controller_name == 'timelines' && action_name == 'show' && @timeline.present?
      view_type = params[:view_type] || 'weeks'
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
end
