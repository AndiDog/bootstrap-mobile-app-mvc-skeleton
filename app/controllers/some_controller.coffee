Controller = require './controller'
mediator = require 'mediator'
SomeView = require 'views/some_view'

module.exports = class SomeController extends Controller
  routes:
    'any/url': 'some'

  initialize: ->
    super
    @view = new SomeView()

    # The view of this controller may redirect to AnotherController, so we have to initialize that one in order to set
    # up the (Backbone) routes. This is lazy loading, but all requireController calls could as well be placed in
    # Application.initControllers.
    mediator.requireController('controllers/another_controller')

  some: ->
    @render('some', @view, {reverse: @getCurrentPageId() is 'another'})
