Controller = require './controller'
mediator = require 'mediator'
HomeView = require 'views/home_view'

module.exports = class HomeController extends Controller
  routes:
    '': 'index'

  initialize: ->
    super
    @view = new HomeView()

    mediator.requireController('controllers/another_controller')
    mediator.requireController('controllers/some_controller')

  index: ->
    options = {reverse: @getCurrentPageId() is 'some' or @getCurrentPageId() is 'another'}

    # Only when the application is starting, don't use a transition
    if @getCurrentPageId() is '_start'
      options.transition = 'none'

    @render('home', @view, options)
