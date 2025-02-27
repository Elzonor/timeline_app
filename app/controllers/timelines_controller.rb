class TimelinesController < ApplicationController
  before_action :set_timeline, only: [:show, :edit, :update, :destroy]

  # GET /timelines
  # GET /timelines.json
  def index
    @timelines = Timeline.all
  end

  # GET /timelines/1
  # GET /timelines/1.json
  def show
    # Forza il reload degli eventi
    @timeline = Timeline.includes(:events).find(params[:id])
    
    if @timeline.events.any?
      # Ordina per start_date discendente (dal più al meno recente)
      # A parità di start_date, ordina per created_at discendente (dal più al meno recente)
      @ordered_events = @timeline.events
        .select('events.*')
        .order('DATE(start_date) DESC, created_at DESC')
      
      @events_by_creation = @timeline.events.order(created_at: :asc).each_with_index.map { |e, i| [e.id, i + 1] }.to_h
      
      # Identifica i gruppi di eventi e i gap
      @event_groups = identify_event_groups(@timeline.events.to_a)
      @gap_weeks = identify_gap_weeks(@event_groups, @timeline.duration_details[:week_dates])
    else
      @ordered_events = []
      @events_by_creation = {}
      @event_groups = []
      @gap_weeks = []
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
        format.html { redirect_to @timeline, notice: 'Timeline was successfully created.' }
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
        format.html { redirect_to @timeline, notice: 'Timeline was successfully updated.' }
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
      format.html { redirect_to timelines_url, notice: 'Timeline was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timeline
      @timeline = Timeline.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def timeline_params
      params.require(:timeline).permit(:name)
    end

    # Identifica i gruppi di eventi basati sulla sovrapposizione temporale
    def identify_event_groups(events)
      # Ordina gli eventi per data di inizio ASCENDENTE (dal meno al più recente)
      sorted_events = events.sort_by(&:start_date)
      groups = []
      current_group = []
      
      sorted_events.each do |event|
        if current_group.empty?
          current_group << event
        else
          # Verifica se l'evento si sovrappone con l'ultimo del gruppo corrente
          last_event_end = current_group.last.end_date || Date.current
          if event.start_date <= last_event_end + 1.week
            current_group << event
          else
            groups << current_group
            current_group = [event]
          end
        end
      end
      
      groups << current_group unless current_group.empty?
      groups
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
      
      # Aggiungi esplicitamente la settimana del 9 febbraio 2025 come gap
      feb_9_2025 = Date.new(2025, 2, 9).beginning_of_week
      all_weeks.each do |week_start|
        if week_start.to_date == feb_9_2025
          gap_weeks << week_start unless gap_weeks.include?(week_start)
          break
        end
      end
      
      gap_weeks
    end
end
