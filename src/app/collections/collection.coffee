SEPARATOR = '-'

# Base class for all collections. Note that Backbone.js's Collection class is not used here.
#
# All CRUD methods work only in memory, not directly in the localStorage. Therefore, all of these methods ensure that
# the collection was fetched at least once.
#
# TODO: methods to find a model instance by comparing attributes e.g. usersCollection.findOne((user) -> user.get('username') is 'admin')
module.exports = class Collection
  # Overwrite this with the collection name (used for local storage), e.g. "UsersCollection"
  name: null

  # Overwrite this with the model class used to instantiate model instances from raw attributes
  model: null

  constructor: ->
    @fetched = false
    @toRemove = []
    @toSave = []

    if not @name
      throw 'Must define name of collection'

  add: (model) ->
    if typeof model.get('id') isnt 'number'
      throw "#{@name}.add: Model ID must be a number (is #{model.get('id')})"

    if @fetched is false
      throw 'Cannot call add(), collection was not fetched yet'

    id = model.get('id')
    for model in @models
      if model.get('id') is id
        throw "Cannot add model because one with the same ID #{id} exists already"

    @models.push(model)
    @toSave.push(model.get('id'))
    return

  count: ->
    @models.length

  fetchLocal: ->
    if @fetched is undefined
      throw 'Constructor not called'
    if not @name? or not @model?
      throw 'Must define a name and model class for collection'

    @models = []
    value = localStorage.getItem(@name)

    fetchedIds = {}

    if value
      ids = (value and value.split(',')) or []

      for id in ids
        if id of fetchedIds
          console.log("Warning: ID fetched twice (#{@constructor.name})")
          continue

        jsonRecord = localStorage.getItem(@name + SEPARATOR + id)
        if not jsonRecord
          console.log("Warning: Item #{id} of #{@name} missing in local storage #{@name + SEPARATOR + id}")
          continue

        modelAttributes = JSON.parse(jsonRecord)
        modelAttributes.id = parseInt(id, 10)
        model = new @model(modelAttributes)
        @models.push(model)

        fetchedIds[id] = true

    @fetched = true
    @

  fetchRemote: ->
    throw "fetchRemote not implemented in #{@name}"

  get: (id) ->
    if @fetched is false
      throw 'Cannot call get(), collection was not fetched yet'

    for model in @models
      if model.get('id') is id
        return model

    return null

  getAll: ->
    if @fetched is false
      throw 'Cannot call getAll(), collection was not fetched yet'

    return @models

  save: (model) ->
    if typeof model.get('id') isnt 'number'
      throw "#{@name}.save: Model ID must be a number (is #{model.get('id')})"

    @models = (m for m in @models when m.get('id') isnt model.get('id'))
    @models.push(model)
    @toSave.push(model.get('id'))
    @toRemove = (id for id in @toRemove when id isnt model.get('id'))
    @

  remove: (model) ->
    if not model
      throw 'Argument null: model'

    if typeof model.get('id') isnt 'number'
      throw "#{@name}.remove: Model ID must be a number (is #{model.get('id')})"

    if @fetched is false
      throw 'Cannot call remove(), collection was not fetched yet'

    @models = (m for m in @models when m.get('id') isnt model.get('id'))
    @toRemove.push(model.get('id'))
    @

  removeAll: ->
    if @fetched is false
      throw 'Cannot call removeAll(), collection was not fetched yet'

    console.log("Remove all of #{@models.length} models")
    for model in @models
      @toRemove.push(model.get('id'))
    @models = []
    @

  syncLocal: ->
    if @fetched is false
      throw 'Cannot call syncLocal(), collection was not fetched yet'

    for id in @toRemove
      localStorage.removeItem(@name + SEPARATOR + id)

    modelsToSave = []
    idsToSave = {}
    for id in @toSave
      idsToSave[id] = true

    for model in @models
      if typeof model.get('id') isnt 'number'
        throw "Model ID must be a number (is #{model.get('id')})"

      if model.get('id') of idsToSave
        modelsToSave.push(model)

    for model in modelsToSave
      localStorage.setItem(@name + SEPARATOR + model.get('id'), JSON.stringify(model.getAttributes()))

    value = (model.get('id') for model in @models).join(',')

    localStorage.setItem(@name, value)

    @toSave = []
    @toRemove = []

    @