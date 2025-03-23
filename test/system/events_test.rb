require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @timeline = timelines(:one)
    @one_day_event = events(:one)
    @multi_day_event = events(:two)
  end

  test "visiting the index" do
    visit timeline_path(@timeline)
    assert_selector "h1", text: @timeline.name
  end

  test "creating a Event" do
    visit timeline_path(@timeline)
    click_on "Aggiungi evento"

    fill_in "event[name]", with: "Nuovo Evento"
    fill_in "event[description]", with: "Descrizione evento"
    fill_in "event[color]", with: "#000000"
    choose "Un giorno"
    fill_in "event[start_date]", with: Date.current
    fill_in "event[end_date]", with: Date.current

    click_on "Crea evento"

    assert_text "Evento creato"
  end

  test "updating a Event" do
    visit timeline_path(@timeline)
    within("#event_#{@one_day_event.id}") do
      click_on "Modifica"
    end

    fill_in "event[name]", with: "Evento Aggiornato"
    click_on "Aggiorna evento"

    assert_text "Evento aggiornato"
  end

  test "destroying a Event" do
    visit timeline_path(@timeline)
    within("#event_#{@one_day_event.id}") do
      accept_confirm do
        click_on "elimina evento"
      end
    end

    assert_text "Evento eliminato"
  end

  test "campi data sono posizionati correttamente nel form di modifica per evento di un giorno" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    
    within(".single-day-container") do
      assert_selector "#date-fields-container"
    end
    within(".multi-day-container") do
      assert_no_selector "#date-fields-container"
    end
  end

  test "campi data sono posizionati correttamente nel form di modifica per evento di più giorni" do
    visit edit_timeline_event_path(@timeline, @multi_day_event)
    
    within(".multi-day-container") do
      assert_selector "#date-fields-container"
    end
    within(".single-day-container") do
      assert_no_selector "#date-fields-container"
    end
  end
end
