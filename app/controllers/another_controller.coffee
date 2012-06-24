Controller = require './controller'

module.exports = class AnotherController extends Controller
  routes:
    'another': 'index'

  initialize: ->
    super
    # Create views and stuff here...

  index: ->
    $('body').html 'Alright, so this is rendered from another controller.'
