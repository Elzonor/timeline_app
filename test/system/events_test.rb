require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @timeline = timelines(:one)
    @event = events(:one)  # evento 1-day
    @multi_day_event = events(:two)  # evento multi-day
  end

  test "i campi data sono posizionati correttamente per un nuovo evento" do
    visit new_timeline_event_path(@timeline)
    
    # Verifica che il radio button "1-day" sia selezionato di default
    assert_selector "#duration_type_single[checked]"
    
    # Verifica che i campi data siano nel contenitore single-day
    within(".single-day-container") do
      assert_selector "#date-fields-container"
    end
    
    # Quando si seleziona "multi-day"
    find("#duration_type_multi").click
    
    # Verifica che i campi data si spostino nel contenitore multi-day
    within(".multi-day-container") do
      assert_selector "#date-fields-container"
    end
  end

  test "i campi data sono posizionati correttamente per un evento esistente 1-day" do
    visit edit_timeline_event_path(@timeline, @event)
    
    # Verifica che il radio button "1-day" sia selezionato
    assert_selector "#duration_type_single[checked]"
    
    # Verifica che i campi data siano nel contenitore single-day
    within(".single-day-container") do
      assert_selector "#date-fields-container"
    end
  end

  test "i campi data sono posizionati correttamente per un evento esistente multi-day" do
    visit edit_timeline_event_path(@timeline, @multi_day_event)
    
    # Verifica che il radio button "multi-day" sia selezionato
    assert_selector "#duration_type_multi[checked]"
    
    # Verifica che i campi data siano nel contenitore multi-day
    within(".multi-day-container") do
      assert_selector "#date-fields-container"
    end
  end
end
