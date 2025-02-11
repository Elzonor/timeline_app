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
    
    # Ordina per start_date discendente (dal più al meno recente)
    # A parità di start_date, ordina per created_at discendente (dal più al meno recente)
    @ordered_events = @timeline.events
      .select('events.*')
      .order('DATE(start_date) DESC, created_at DESC')
    
    @events_by_creation = @timeline.events.order(created_at: :asc).each_with_index.map { |e, i| [e.id, i + 1] }.to_h
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
end
