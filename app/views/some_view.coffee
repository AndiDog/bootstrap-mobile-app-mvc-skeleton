View = require './view'
template = require './templates/some'

module.exports = class HomeView extends View
  id: 'some-view'
  template: template
