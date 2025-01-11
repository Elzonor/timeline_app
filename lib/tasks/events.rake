namespace :events do
  desc 'Assegna colori agli eventi esistenti'
  task assign_colors: :environment do
    Event.where.not(timeline_id: nil).find_each do |event|
      event.assign_color
      event.save!
    end
    puts "Colori assegnati con successo a tutti gli eventi"
  end
end 