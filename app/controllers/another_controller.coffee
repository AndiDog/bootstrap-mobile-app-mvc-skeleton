Controller = require './controller'
AnotherView = require 'views/another_view'

module.exports = class AnotherController extends Controller
  routes:
    'another': 'index'

  initialize: ->
    super
    @view = new AnotherView()

  index: ->
    @render('another', @view)
