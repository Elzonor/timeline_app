module Timelines
  class EventsController < ApplicationController
    before_action :get_timeline
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    def index
      @events = @timeline.events
    end

    def show
    end

    def new
      @event = @timeline.events.new
    end

    def edit
    end

    def create
      @event = @timeline.events.new(event_params)
      process_duration_type
      
      respond_to do |format|
        if @event.save
          format.html { redirect_to timeline_path(@timeline), notice: t('messages.event_created') }
          format.json { render :show, status: :created, location: [@timeline, @event] }
        else
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      process_duration_type
      
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to timeline_path(@timeline), notice: t('messages.event_updated') }
          format.json { render :show, status: :ok, location: [@timeline, @event] }
        else
          format.html { render :edit }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to timeline_path(@timeline), notice: t('messages.event_deleted') }
        format.json { head :no_content }
      end
    end

    private
      def get_timeline
        @timeline = Timeline.find(params[:timeline_id])
      end

      def set_event
        @event = @timeline.events.find(params[:id])
      end

      def event_params
        params.require(:event).permit(:name, :description, :color, :start_date, :end_date, :event_type, :event_duration)
      end
      
      # Processa il parametro duration_type e imposta event_type e event_duration
      def process_duration_type
        return unless params[:duration_type].present?
        
        if params[:duration_type] == '1-day'
          @event.event_duration = '1-day'
          @event.end_date = @event.start_date if @event.start_date.present?
        elsif params[:duration_type] == 'multi-day'
          @event.event_duration = 'multi-day'
        end
        
        # Imposta event_type su 'closed' se c'è una data di fine, altrimenti 'open'
        @event.event_type = @event.end_date.present? ? 'closed' : 'open'
      end
  end
end 