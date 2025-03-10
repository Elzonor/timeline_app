# Timelinez

## Descrizione

Timelinez è un'applicazione per la visualizzazione di eventi su un asse temporale. Può essere usata per rappresentare qualsiasi successione di eventi, dall'intera vita di una persona alla documentazione delle fasi di un progetto, passando per la cartella cliica di un paziente.

## Concetti fondamentali

Una timeline può essere composta da un numero indefinito di eventi e ciascun evento può appartenere a una timeline soltanto. Esistono due **tipologie** di eventi: *1-day* (eventi che durano un giorno soltanto) oppure *multi-day* (eventi che durano più di un giorno). 
Lo **stato** di un evento può essere *chiuso* (data_inizio e data_fine entrambe specificate) oppure *aperto* (data_inizio specificata, data_fine non specificata). 
Tutti gli eventi di tipo *1-day* hanno, per definizione, lo stato *chiuso*. Inoltre, tutti gli eventi *nel futuro* possono avere soltanto lo stato *chiuso* (non deve essere possibile creare eventi nel futuro senza specificare la data_fine).

## Rappresentazione degli eventi su una timeline

