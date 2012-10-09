Controller = require('./controller')
SettingsView = require('views/settings')
DetailSettingsView = require('views/detail_settings')

module.exports = class SettingsController extends Controller
  routes:
    'route-for-settings': 'settings'
    'route-for-detailed-settings': 'detail'

  initialize: ->
    super

    # We won't pop the first screen ("view") on the settings tab, so keep that view as instance variable
    @view = new SettingsView()

    # Example of interacting with view events (you may or may not want to do this in the controller, depending on
    # whether you prefer business logic to be in the V or the C of "MVC"...)
    oldMethod = @view.onPageBeforeShow
    @view.onPageBeforeShow = ->
      # Kind of "super" call
      oldMethod.apply(@)

      console.log('Detected that settings screen is about to be shown, here is a good place to update the DOM with ' +
                  'current data')

  detail: ->
    return @render(new DetailSettingsView())

  settings: ->
    # Must return the view here (note that @render returns the view)
    return @render(@view)