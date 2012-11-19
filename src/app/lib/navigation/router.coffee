# Handles routing, i.e. matching a route with a controller's method and calling it to render a view.
#
# Note that Backbone's routing is NOT used (do not call Backbone.history.start or any of its methods) and there is no
# idea of listening to hash changes at the moment.
#
# This class only handles very simple routing, i.e. mapping a fixed route string (without any possible parameters) to
# the respective controller method. More advanced routing libraries could be added here.
class Router
  constructor: ->
    @routes = {}

    # This class handles page loading which is triggered by hist.push, for example
    mediator.subscribe 'must-load-fragment', (fragment, queueName, onSuccess) =>
      view = @renderRoute(fragment)

      if view is null
        return

      if 'getHtmlElement' not of view
        throw "No view returned, does controller method return the view? (view=#{view})"

      if not view.getHtmlElement()
        throw "Controller returned view that is not rendered (view=#{view})"

      if onSuccess?
        onSuccess(view)

  addRoute: (pattern, method) ->
    if pattern of @routes
      throw "Route '#{pattern}' already exists"

    @routes[pattern] = method

  renderRoute: (pattern) ->
    if pattern not of @routes
      throw "Route '#{pattern}' not found, is the controller loaded?"

    # Call the controller's method here (which must return a view)
    view = @routes[pattern]()

    if view is null
      # Controller does not want to display anything at the moment (or will be done asynchronously)
      return null

    if not view
      throw "Controller did not return a view for route '#{pattern}'"

    if not view.getHtmlElement()
      throw 'View did not create an HTML element'

    return view

module.exports = new Router()