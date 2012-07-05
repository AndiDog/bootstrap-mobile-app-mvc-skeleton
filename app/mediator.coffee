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

mediator = {}

# Publish / Subscribe
# -------------------

# Mixin event methods from Backbone.Events,
# create Publish/Subscribe aliases
mediator.subscribe = Backbone.Events.on
mediator.unsubscribe = Backbone.Events.off
mediator.publish = mediator.trigger = Backbone.Events.trigger

# (Lazy) Loading of controllers identical to the require() function
mediator.loadedControllerInstances = {}
mediator.requireController = (controllerRequirePath) ->
  if controllerRequirePath of mediator.loadedControllerInstances
    return

  if not /^controllers\//.test(controllerRequirePath)
    throw 'Use mediator.requireController() as you would use require()'

  instance = new (require(controllerRequirePath))()
  mediator.loadedControllerInstances[controllerRequirePath] = instance

  return instance

module.exports = mediator