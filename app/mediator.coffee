# Mediator
# --------

# The mediator is a simple object all others modules use to communicate
# with each other. It implements the Publish/Subscribe pattern.
#
# Additionally, it holds objects which need to be shared between modules.
#
# This module returns the singleton object. This is the
# application-wide mediator you might load into modules
# which need to talk to other modules using Publish/Subscribe.

class Mediator
  subscribe: Backbone.Events.on
  unsubscribe: Backbone.Events.off
  trigger: Backbone.Events.trigger

  # (Lazy) Loading of controllers identical to the require() function
  loadedControllerInstances: {}
  requireController: (controllerRequirePath) ->
    if controllerRequirePath of @loadedControllerInstances
      return @loadedControllerInstances[controllerRequirePath]

    if not /^controllers\//.test(controllerRequirePath)
      throw 'Use mediator.requireController() as you would use require()'

    instance = new (require(controllerRequirePath))()
    @loadedControllerInstances[controllerRequirePath] = instance

    return instance

  # (Lazy) Loading of collections identical to the require() function
  loadedCollectionInstances: {}
  requireCollection: (collectionRequirePath, fetchAfterCreation=true) ->
    if collectionRequirePath of @loadedCollectionInstances
      return @loadedCollectionInstances[collectionRequirePath]

    if not /^collections\//.test(collectionRequirePath)
      throw 'Use mediator.requireCollection() as you would use require()'

    instance = new (require(collectionRequirePath))()
    @loadedCollectionInstances[collectionRequirePath] = instance

    if fetchAfterCreation
      match = /\/([a-z]+)$/.exec(collectionRequirePath)
      if match is null
        throw 'Assertion failed: Controller path must end with [a-z]+'

      collectionNameLower = match[1]
      instance.fetchLocal()
      @trigger('collection-fetched-after-creation', collectionNameLower, instance)

    return instance

  loadedServiceInstances: {}
  registeredServices: {}

  # Use overwrite parameter for mockups
  registerService: (serviceName, requirePath, overwrite=false) ->
    if serviceName of @registeredServices and not overwrite
      throw "Cannot register service #{serviceName} twice"

    @registeredServices[serviceName] = requirePath

  requireService: (serviceName) ->
    if serviceName of @loadedServiceInstances
      return @loadedServiceInstances[serviceName]

    if not /^[a-zA-Z]+$/.test(serviceName)
      throw 'Service name must match [a-zA-Z]+'

    if serviceName not of @registeredServices
      throw "Service #{serviceName} not registered"

    instance = new (require(@registeredServices[serviceName]))()
    @loadedServiceInstances[serviceName] = instance

    return instance

module.exports = new Mediator()