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

    @view.findHtmlElement('#create-user-button').click ->
      usersCollection = mediator.requireCollection('collections/users')

      # If you take a look at the implementation of mediator.requireCollection, you will see that the collection is
      # fetched from local storage as soon as it's loaded the first time. No need to fetch again here.
      users = usersCollection.getAll()
      console.log("Have #{users.length} users stored:")
      for user in users
        console.log("- #{user.get('username')} <#{user.get('email')}>) created #{user.get('creationDateStr')}")

      # Now add a new user (will replace existing one with the same generated ID, see UserModel class)
      UserModel = require('models/user')
      newUser = new UserModel(
        username: 'AndiDog'
        email: "spam@example.org"
        creationDateStr: "#{new Date()}"
      )
      usersCollection.save(newUser)

      console.log('Added new user')

      # At this line, the user only exists in memory (in the users collection), so we have to store it (uses local
      # storage, so you can see this in the developer console)
      usersCollection.syncLocal()

    return @view