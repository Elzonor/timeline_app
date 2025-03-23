// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"

const application = Application.start()

// Registra tutti i controller nella directory controllers
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))

// Funzione per registrare i controller
function definitionsFromContext(context) {
  return context.keys()
    .map(key => {
      const identifier = key.replace(/^\.\//, '').replace(/\_controller\.js$/, '')
      const controllerModule = context(key)
      return { identifier, controllerModule: controllerModule.default }
    })
}
