SidebarView = require('./sidebar_view')
template = require('./templates/home')
sidebarTemplate = require('./templates/sidebar')

module.exports = class HomeView extends SidebarView
  template: template

  renderSidebar: -> sidebarTemplate()