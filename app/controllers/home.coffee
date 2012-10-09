Controller = require('./controller')
HomeView = require('views/home')

module.exports = class HomeController extends Controller
  routes:
    'route-for-home': 'index'

  initialize: ->
    super
    @view = new HomeView()

    # Here you may want to load other controllers whose routes may be accessed by views of this controller
    #mediator.requireController('controllers/another')

  index: ->
    @view.setViewData({someViewData: 42})
    @render(@view)

    return @view