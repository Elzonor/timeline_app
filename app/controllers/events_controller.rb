class EventsController < ApplicationController
	before_action :get_timeline
	before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = @timeline.events
  end

  # GET /events/1
  # GET /events/1.json
  def show	
  end

  # GET /events/new
  def new
    @event = @timeline.events.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = @timeline.events.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to timeline_path(@timeline), notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: [@timeline, @event] }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to timeline_path(@timeline), notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: [@timeline, @event] }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to timeline_path(@timeline), notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
		def get_timeline
			@timeline = Timeline.find(params[:timeline_id])
		end

		# Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = @timeline.events.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:name, :description, :timeline_id, :start_date, :end_date)
    end
end
