# Base class for all models.
module.exports = class Model
  constructor: (attributes) ->
    @attributes = _.extend({}, @defaults ? {}, attributes)

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

  # Loading from saved attributes (e.g. from localStorage) is different because some model classes may not allow an 'id'
  # attribute to be passed to the constructor (e.g. if it's automatically generated). Therefore, this class method can
  # be used to overwrite the validation behavior.
  @fromSavedAttributes: (attributes) -> new @(attributes)

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