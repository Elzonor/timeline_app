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
    
    # Usa gli ID per i radio button
    find("#duration_type_single").click
    
    fill_in "event[start_date]", with: Date.current
    fill_in "event[end_date]", with: Date.current

    click_on "Crea evento"

    assert_text "Evento creato"
  end

  test "updating a Event" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    
    fill_in "event[name]", with: "Evento Aggiornato"
    click_on "Aggiorna evento"

    assert_text "Evento aggiornato"
  end

  test "destroying a Event" do
    # Per evitare problemi con la finestra di conferma in ambiente di test,
    # possiamo disabilitare le conferme JavaScript
    page.execute_script('window.confirm = function() { return true; }')
    
    # Visita la pagina di modifica dell'evento
    visit edit_timeline_event_path(@timeline, @one_day_event)
    
    # Memo il nome dell'evento per verificarne la rimozione
    event_name = @one_day_event.name
    
    # Clicca sul link per eliminare l'evento
    click_on "elimina evento"
    
    # Dobbiamo attendere che il reindirizzamento venga completato
    sleep 1
    
    # Verifica che il messaggio flash sia presente
    assert_text "Evento eliminato"
    
    # Verifica che l'evento sia stato eliminato
    assert_no_text event_name
  end

  test "campi data sono posizionati correttamente nel form di modifica per evento di un giorno" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    
    # Aspetta che il JavaScript sposti i campi data nel contenitore corretto
    sleep 0.5
    assert_selector "#date-fields-container", count: 1
    # Verifica che il radio button per eventi di un giorno sia selezionato
    assert_selector "#duration_type_single[checked]"
  end

  test "campi data sono posizionati correttamente nel form di modifica per evento di più giorni" do
    visit edit_timeline_event_path(@timeline, @multi_day_event)
    
    # Aspetta che il JavaScript sposti i campi data nel contenitore corretto
    sleep 0.5
    assert_selector "#date-fields-container", count: 1
    # Verifica che il radio button per eventi di più giorni sia selezionato
    assert_selector "#duration_type_multi[checked]"
  end

  test "variazione durata da 1-day a multi-day" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    find("#duration_type_multi").click
    fill_in "event[end_date]", with: Date.current + 2
    click_on "Aggiorna evento"
    assert_text "Evento aggiornato"
    assert_selector "#duration_type_multi[checked]"
  end

  test "variazione colore da verde a blu" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    fill_in "event[color]", with: "#0000FF"
    click_on "Aggiorna evento"
    assert_text "Evento aggiornato"
    assert_selector "[style='background-color: #0000FF;']"
  end

  test "eliminazione evento con conferma" do
    visit edit_timeline_event_path(@timeline, @one_day_event)
    page.accept_confirm do
      click_on "elimina evento"
    end
    assert_text "Evento eliminato"
  end
end
