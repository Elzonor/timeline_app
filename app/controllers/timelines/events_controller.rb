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
        params.require(:event).permit(:name, :description, :start_date, :end_date, :color)
      end
  end
end 