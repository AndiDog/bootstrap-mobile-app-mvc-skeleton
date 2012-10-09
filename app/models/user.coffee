Model = require('./model')

# Since this skeleton assumes that all models have an attribute 'id', this model class will create one automatically
# from the username and email attributes.
module.exports = class UserModel extends Model
  # Attributes: id (unique ID created by mobile app), username, email, creationDateStr

  constructor: (attributes) ->
    super

    if 'id' not of attributes
      hash = @calculateHash('username', 'email')

      @set('id', hash)