#SomeController = require 'controllers/some_controller'

# The application bootstrapper.
Application =
  initialize: ->
    Router = require 'lib/router'

    @initControllers()

    # Instantiate the default router
    @router = new Router()

    # Freeze the object
    Object.freeze? this

  initControllers: ->
    # These controllers are active during the whole application runtime.
    # You don’t need to instantiate all controllers here, only special
    # controllers which do not to respond to routes. They may govern models
    # and views which are needed the whole time, for example header, footer
    # or navigation views.
    # e.g. new NavigationController()

    # This instantiates the example controller containing the home page. That's necessary because the default route
    # redirects to that controller.
    mediator = require 'mediator'
    mediator.requireController('controllers/some_controller')

module.exports = Application
