Controller = require './controller'
mediator = require 'mediator'
SomeModel = require 'models/some_model'
SomeView = require 'views/some_view'

module.exports = class SomeController extends Controller
  routes:
    'any/url': 'some'

  initialize: ->
    super
    @model = new SomeModel()
    @view = new SomeView({@model})

    # The view of this controller may redirect to AnotherController, so we have to initialize that one in order to set
    # up the (Backbone) routes. This is lazy loading, but all requireController calls could as well be placed in
    # Application.initControllers.
    mediator.requireController('controllers/another_controller')

  some: ->
    $('body').html @view.render().el
