application = require 'application'

module.exports = class Router extends Backbone.Router
  routes:
    '': 'home'

  home: ->
    this.navigate('any/url', {trigger: true, replace: true})
