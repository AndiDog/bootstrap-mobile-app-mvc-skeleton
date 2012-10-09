Collection = require('./collection')
UserModel = require('models/user')

module.exports = class UsersCollection extends Collection
  model: UserModel

  # Name of the collection is used for local storage
  name: 'UsersCollection'