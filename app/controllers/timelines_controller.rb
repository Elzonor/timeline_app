class TimelinesController < ApplicationController
  before_action :set_timeline, only: [:show, :edit, :update, :destroy]

  # GET /timelines
  # GET /timelines.json
  def index
    @timelines = Timeline.includes(:events)
                        .select('timelines.*, COUNT(events.id) as events_count')
                        .left_joins(:events)
                        .group('timelines.id, timelines.created_at')
                        .order('timelines.created_at ASC')
  end

  # GET /timelines/1
  # GET /timelines/1.json
  def show
    @view = params[:view] || 'days'
    @view_type = params[:view_type]
    
    if @view_type.present?
      # Se viene specificato un view_type nei params, aggiorna/crea la preferenza
      @timeline.preference&.destroy
      @timeline.create_preference(view_type: @view_type)
    else
      # Altrimenti usa la preferenza salvata o il default
      @view_type = @timeline.preferred_view_type
    end
    
    if @timeline.events.loaded?
      load_and_process_events
    else
      initialize_empty_collections
    end
  end

  # GET /timelines/new
  def new
    @timeline = Timeline.new
  end

  # GET /timelines/1/edit
  def edit
  end

  # POST /timelines
  # POST /timelines.json
  def create
    @timeline = Timeline.new(timeline_params)

    respond_to do |format|
      if @timeline.save
        format.html { redirect_to @timeline, notice: t('messages.timeline_created') }
        format.json { render :show, status: :created, location: @timeline }
      else
        format.html { render :new }
        format.json { render json: @timeline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timelines/1
  # PATCH/PUT /timelines/1.json
  def update
    respond_to do |format|
      if @timeline.update(timeline_params)
        format.html { redirect_to @timeline, notice: t('messages.timeline_updated') }
        format.json { render :show, status: :ok, location: @timeline }
      else
        format.html { render :edit }
        format.json { render json: @timeline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timelines/1
  # DELETE /timelines/1.json
  def destroy
    @timeline.destroy
    respond_to do |format|
      format.html { redirect_to timelines_url, notice: t('messages.timeline_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timeline
      @timeline = if action_name == 'show'
        Timeline.includes(:events).find(params[:id])
      else
        Timeline.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def timeline_params
      params.require(:timeline).permit(:name)
    end
    
    def load_and_process_events
      @ordered_events = sort_events_by_recency(@timeline.events)
      @events_by_creation = create_events_creation_map(@timeline.events)
      @event_groups = identify_event_groups(@timeline.events.to_a)
      load_time_units_and_gaps
    end

    def initialize_empty_collections
      @ordered_events = []
      @events_by_creation = {}
      @event_groups = []
      @time_units = []
      @gap_units = []
    end

    def sort_events_by_recency(events)
      events.sort do |a, b|
        if a.end_date.nil? && b.end_date.nil?
          b.start_date <=> a.start_date
        elsif a.end_date.nil?
          1
        elsif b.end_date.nil?
          -1
        else
          if a.end_date == b.end_date
            b.start_date <=> a.start_date
          else
            b.end_date <=> a.end_date
          end
        end
      end
    end

    def create_events_creation_map(events)
      events.sort_by(&:created_at)
            .each_with_index
            .map { |e, i| [e.id, i + 1] }
            .to_h
    end

    def load_time_units_and_gaps
      return initialize_empty_collections unless @timeline.duration_details

      @time_units = case @view_type
                   when 'days'
                     @timeline.duration_details[:day_dates].reverse
                   when 'weeks'
                     @timeline.duration_details[:week_dates].reverse
                   when 'months'
                     @timeline.duration_details[:month_dates].reverse
                   when 'years'
                     @timeline.duration_details[:year_dates].reverse
                   else
                     @timeline.duration_details[:week_dates].reverse
                   end

      @gap_units = case @view_type
                  when 'days'
                    identify_gap_days(@event_groups, @time_units)
                  when 'weeks'
                    identify_gap_weeks(@event_groups, @time_units)
                  when 'months'
                    identify_gap_months(@event_groups, @time_units)
                  when 'years'
                    identify_gap_years(@event_groups, @time_units)
                  else
                    identify_gap_weeks(@event_groups, @time_units)
                  end
    end

    # Identifica i gruppi di eventi che si sovrappongono
    def identify_event_groups(events)
      # Ordina gli eventi per data di inizio
      sorted_events = events.sort_by(&:start_date)
      
      # Inizializza i gruppi
      groups = []
      current_group = []
      
      sorted_events.each do |event|
        if current_group.empty?
          # Se non ci sono eventi nel gruppo corrente, inizia un nuovo gruppo
          current_group << event
        else
          # Trova la data di fine più recente nel gruppo corrente
          latest_end_date = current_group.map { |e| e.end_date || Date.current }.max
          
          # Se l'evento inizia prima o lo stesso giorno in cui finisce l'ultimo evento del gruppo
          # allora fa parte dello stesso gruppo
          if event.start_date <= latest_end_date
            current_group << event
          else
            # Altrimenti, chiudi il gruppo corrente e iniziane uno nuovo
            groups << current_group
            current_group = [event]
          end
        end
      end
      
      # Aggiungi l'ultimo gruppo se non è vuoto
      groups << current_group unless current_group.empty?
      
      groups
    end

    # Identifica i giorni che sono gap tra gruppi di eventi
    def identify_gap_days(event_groups, all_days)
      gap_days = []
      
      # Se non ci sono gruppi, non ci sono gap
      return gap_days if event_groups.empty?
      
      # Aggiungi un giorno gap prima del primo gruppo di eventi
      if event_groups.any?
        first_group = event_groups.first
        earliest_start_date = first_group.map { |e| e.start_date.to_date }.min
        
        # Trova il primo giorno prima dell'inizio del primo gruppo
        first_day_before_events = nil
        all_days.each do |day|
          day_date = day.to_date
          if day_date < earliest_start_date
            first_day_before_events = day
            break
          end
        end
        
        # Aggiungi il giorno gap prima del primo gruppo, se esiste
        gap_days << first_day_before_events if first_day_before_events
      end
      
      # Se non ci sono abbastanza gruppi per i gap tra gruppi, ritorna
      return gap_days if event_groups.length <= 1
      
      # Per ogni coppia di gruppi consecutivi
      (0...event_groups.length - 1).each do |i|
        group1 = event_groups[i]
        group2 = event_groups[i + 1]
        
        # Trova la data di fine più recente del primo gruppo
        latest_end_date = group1.map { |e| e.end_date&.to_date || Date.current }.max
        
        # Trova la data di inizio più antica del secondo gruppo
        earliest_start_date = group2.map { |e| e.start_date.to_date }.min
        
        # Calcola la differenza in giorni
        days_difference = (earliest_start_date - latest_end_date).to_i
        
        # Se c'è almeno un giorno di gap
        if days_difference > 1
          # Calcola i giorni che cadono nel gap
          gap_start = latest_end_date.to_date
          
          # Trova tutti i giorni che cadono nel gap
          gap_candidates = []
          all_days.each do |day|
            day_date = day.to_date
            
            # Verifica se il giorno cade nel gap
            if day_date > gap_start && day_date < earliest_start_date
              gap_candidates << day
            end
          end
          
          # Aggiungi solo l'ultimo giorno del gap, se esiste
          gap_days << gap_candidates.last unless gap_candidates.empty?
        end
      end
      
      gap_days
    end

    # Identifica le settimane che sono gap tra gruppi di eventi
    def identify_gap_weeks(event_groups, all_weeks)
      gap_weeks = []
      
      # Se non ci sono gruppi, non ci sono gap
      return gap_weeks if event_groups.empty?
      
      # Aggiungi una settimana gap prima del primo gruppo di eventi
      if event_groups.any?
        first_group = event_groups.first
        earliest_start_date = first_group.map { |e| e.start_date.to_date }.min
        
        # Trova la prima settimana prima dell'inizio del primo gruppo
        first_week_before_events = nil
        all_weeks.each do |week_start|
          week_start_date = week_start.to_date
          if week_start_date < earliest_start_date && 
             week_start_date.beginning_of_week != earliest_start_date.beginning_of_week
            first_week_before_events = week_start
            break
          end
        end
        
        # Aggiungi la settimana gap prima del primo gruppo, se esiste
        gap_weeks << first_week_before_events if first_week_before_events
      end
      
      # Se non ci sono abbastanza gruppi per i gap tra gruppi, ritorna
      return gap_weeks if event_groups.length <= 1
      
      # Per ogni coppia di gruppi consecutivi
      (0...event_groups.length - 1).each do |i|
        group1 = event_groups[i]
        group2 = event_groups[i + 1]
        
        # Trova la data di fine più recente del primo gruppo
        latest_end_date = group1.map { |e| e.end_date&.to_date || Date.current }.max
        
        # Trova la data di inizio più antica del secondo gruppo
        earliest_start_date = group2.map { |e| e.start_date.to_date }.min
        
        # Calcola la differenza in giorni
        days_difference = (earliest_start_date - latest_end_date).to_i
        
        # Se c'è almeno una settimana di gap
        if days_difference > 7
          # Calcola le settimane che cadono nel gap
          gap_start = latest_end_date.to_date
          
          # Trova tutte le settimane che cadono nel gap
          gap_candidates = []
          all_weeks.each do |week_start|
            week_start_date = week_start.to_date
            
            # Verifica se la settimana cade nel gap
            # Consideriamo una settimana come gap se:
            # 1. Inizia dopo la fine del primo gruppo
            # 2. Non è la stessa settimana dell'inizio del secondo gruppo
            # 3. Inizia prima dell'inizio del secondo gruppo
            if week_start_date > gap_start && 
               week_start_date.beginning_of_week != earliest_start_date.beginning_of_week &&
               week_start_date < earliest_start_date
              gap_candidates << week_start
            end
          end
          
          # Aggiungi solo l'ultima settimana del gap, se esiste
          gap_weeks << gap_candidates.last unless gap_candidates.empty?
        end
      end
      
      gap_weeks
    end
    
    # Identifica i mesi che sono gap tra gruppi di eventi
    def identify_gap_months(event_groups, all_months)
      gap_months = []
      
      # Se non ci sono gruppi, non ci sono gap
      return gap_months if event_groups.empty?
      
      # Aggiungi un mese gap prima del primo gruppo di eventi
      if event_groups.any?
        first_group = event_groups.first
        earliest_start_date = first_group.map { |e| e.start_date.to_date }.min
        
        # Trova il primo mese prima dell'inizio del primo gruppo
        first_month_before_events = nil
        all_months.each do |month_start|
          month_start_date = month_start.to_date
          if month_start_date < earliest_start_date && 
             month_start_date.beginning_of_month != earliest_start_date.beginning_of_month
            first_month_before_events = month_start
            break
          end
        end
        
        # Aggiungi il mese gap prima del primo gruppo, se esiste
        gap_months << first_month_before_events if first_month_before_events
      end
      
      # Se non ci sono abbastanza gruppi per i gap tra gruppi, ritorna
      return gap_months if event_groups.length <= 1
      
      # Per ogni coppia di gruppi consecutivi
      (0...event_groups.length - 1).each do |i|
        group1 = event_groups[i]
        group2 = event_groups[i + 1]
        
        # Trova la data di fine più recente del primo gruppo
        latest_end_date = group1.map { |e| e.end_date&.to_date || Date.current }.max
        
        # Trova la data di inizio più antica del secondo gruppo
        earliest_start_date = group2.map { |e| e.start_date.to_date }.min
        
        # Calcola la differenza in giorni
        days_difference = (earliest_start_date - latest_end_date).to_i
        
        # Se c'è almeno un mese di gap (approssimativamente 30 giorni)
        if days_difference > 30
          # Calcola i mesi che cadono nel gap
          gap_start = latest_end_date.to_date
          
          # Trova tutti i mesi che cadono nel gap
          gap_candidates = []
          all_months.each do |month_start|
            month_start_date = month_start.to_date
            
            # Verifica se il mese cade nel gap
            if month_start_date > gap_start && 
               month_start_date.beginning_of_month != earliest_start_date.beginning_of_month &&
               month_start_date < earliest_start_date
              gap_candidates << month_start
            end
          end
          
          # Aggiungi solo l'ultimo mese del gap, se esiste
          gap_months << gap_candidates.last unless gap_candidates.empty?
        end
      end
      
      gap_months
    end
    
    # Identifica gli anni che sono gap tra gruppi di eventi
    def identify_gap_years(event_groups, all_years)
      gap_years = []
      
      # Se non ci sono gruppi, non ci sono gap
      return gap_years if event_groups.empty?
      
      # Aggiungi un anno gap prima del primo gruppo di eventi
      if event_groups.any?
        first_group = event_groups.first
        earliest_start_date = first_group.map { |e| e.start_date.to_date }.min
        
        # Trova il primo anno prima dell'inizio del primo gruppo
        first_year_before_events = nil
        all_years.each do |year_start|
          year_start_date = year_start.to_date
          if year_start_date < earliest_start_date && 
             year_start_date.beginning_of_year != earliest_start_date.beginning_of_year
            first_year_before_events = year_start
            break
          end
        end
        
        # Aggiungi l'anno gap prima del primo gruppo, se esiste
        gap_years << first_year_before_events if first_year_before_events
      end
      
      # Se non ci sono abbastanza gruppi per i gap tra gruppi, ritorna
      return gap_years if event_groups.length <= 1
      
      # Per ogni coppia di gruppi consecutivi
      (0...event_groups.length - 1).each do |i|
        group1 = event_groups[i]
        group2 = event_groups[i + 1]
        
        # Trova la data di fine più recente del primo gruppo
        latest_end_date = group1.map { |e| e.end_date&.to_date || Date.current }.max
        
        # Trova la data di inizio più antica del secondo gruppo
        earliest_start_date = group2.map { |e| e.start_date.to_date }.min
        
        # Calcola la differenza in giorni
        days_difference = (earliest_start_date - latest_end_date).to_i
        
        # Se c'è almeno un anno di gap (approssimativamente 365 giorni)
        if days_difference > 365
          # Calcola gli anni che cadono nel gap
          gap_start = latest_end_date.to_date
          
          # Trova tutti gli anni che cadono nel gap
          gap_candidates = []
          all_years.each do |year_start|
            year_start_date = year_start.to_date
            
            # Verifica se l'anno cade nel gap
            if year_start_date > gap_start && 
               year_start_date.beginning_of_year != earliest_start_date.beginning_of_year &&
               year_start_date < earliest_start_date
              gap_candidates << year_start
            end
          end
          
          # Aggiungi solo l'ultimo anno del gap, se esiste
          gap_years << gap_candidates.last unless gap_candidates.empty?
        end
      end
      
      gap_years
    end
end
