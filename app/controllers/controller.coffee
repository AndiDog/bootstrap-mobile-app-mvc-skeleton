# Base class for all controllers.
module.exports = class Controller extends Backbone.Router
  getCurrentPageId: ->
    return $('[data-role="page"]').attr('id')

  render: (id, view, options) ->
    view.render()

    # If the template already defines a JQM page, use it
    existingPage = view.$el.find('[data-role="page"]')

    if existingPage.length > 1
      throw 'Expected exactly 0 or 1 JQM pages'
    else if existingPage.length is 0
      view.$el.attr('data-role', 'page')
      existingPage = view.$el

    existingPage.attr('id', id)

    $('body').append(view.$el)

    settings = $.extend({transition: 'slide', changeHash: false}, options)
    $.mobile.changePage(existingPage, settings)
