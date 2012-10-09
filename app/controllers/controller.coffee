# Base class for all controllers.
module.exports = class Controller
  constructor: ->
    console.log("Constructing controller #{@constructor.name}")

    router = require('lib/navigation/router')
    for key, value of @routes
      # value is a method name
      controllerMethod = this[value]

      if not controllerMethod
        throw "Controller #{@constructor.name} does not have a method #{value} (route '#{key}')"

      router.addRoute(key, _.bind(controllerMethod, this))

    @initialize()

  initialize: ->
    console.log("Initializing controller #{@constructor.name}")

  render: (view) ->
    # This will return the view again
    return view.render()
