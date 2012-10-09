# Base class for all models.
module.exports = class Model
  constructor: (attributes) ->
    @attributes = _.extend({}, _.clone(@defaults ? {}), attributes)

  calculateHash: (attributeNames...) ->
    l = []
    for attributeName in attributeNames
      l.push(@attributes[attributeName])

    representation = JSON.stringify(l)

    hash = 0

    for i in [0...representation.length]
        ch = representation.charCodeAt(i)
        hash = ((hash << 5) - hash) + ch;
        hash = hash & hash

    return hash

  get: (attributeName) ->
    @attributes[attributeName]

  getAttributes: ->
    @attributes

  set: (attributesOrName, value) ->
    if typeof value is 'undefined'
      # attributesOrName must be a dictionary
      for key, value of attributesOrName
        @attributes[key] = value
    else
      @attributes[attributesOrName] = value