require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @timeline = timelines(:one)
    @event = Event.new(
      name: "Test Event",
      start_date: Date.current,
      timeline: @timeline
    )
  end

  test "should be valid with basic attributes" do
    assert @event.valid?
  end

  test "should require end_date for future events" do
    @event.start_date = Date.tomorrow
    assert_not @event.valid?
    assert_includes @event.errors[:end_date], "non può essere lasciato vuoto"
  end

  test "should not require end_date for past events" do
    @event.start_date = Date.yesterday
    assert @event.valid?
  end

  test "should be multi-day when end_date is different from start_date" do
    @event.start_date = Date.current
    @event.end_date = Date.tomorrow
    @event.save
    assert_equal "multi-day", @event.event_duration
  end

  test "should be one-day when end_date equals start_date" do
    @event.start_date = Date.current
    @event.end_date = Date.current
    @event.save
    assert_equal "1-day", @event.event_duration
  end

  test "should be closed when end_date is present" do
    @event.start_date = Date.current
    @event.end_date = Date.current
    @event.save
    assert_equal "closed", @event.event_type
  end

  test "should be open when end_date is nil" do
    @event.start_date = Date.yesterday
    @event.save
    assert_equal "open", @event.event_type
  end

  test "should not allow end_date before start_date" do
    @event.start_date = Date.current
    @event.end_date = Date.yesterday
    assert_not @event.valid?
    assert_includes @event.errors[:end_date], "deve essere successiva alla data di inizio"
  end
end
