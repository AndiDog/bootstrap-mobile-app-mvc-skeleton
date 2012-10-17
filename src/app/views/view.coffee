crossPlatform = require('lib/cross_platform')

# Ensure template handlers are loaded
require('views/handlebars_helpers')

# Base class for all views.
module.exports = class View
  # Override with true to be notified when the screen size changes between tablet and phone, or the aspect ratio changes
  # between portrait and landscape. Do not change this value at runtime.
  #
  # See also onScreenSizeChanged.
  needsScreenSizeEvents: false

  afterRender: ->
    # Turn it into a jQM page
    # If the template already defines a JQM page, use it
    existingPage = @$el.find('[data-role="page"]')

    if existingPage.length > 1
      throw 'Expected exactly 0 or 1 JQM pages'
    else if existingPage.length is 0
      if @$el.length isnt 1
        throw "Template of #{@constructor.name} must have a top-level element (usually a DIV)"

      existingPage = @$el
      existingPage.addClass('page')

    @translate()

    # Register creation and destruction events
    $(@$el).live 'pagecreate', =>
      @onPageCreate()

    $(@$el).live 'pageremove', =>
      @onPageRemove()

    # Register show and hide events
    $(@$el).live 'pagebeforeshow', =>
      @onPageBeforeShow()

    $(@$el).live 'pagehide', =>
      @onPageHide()

  findHtmlElement: (query) -> @$el.find(query)

  getHtmlElement: -> @$el

  getViewData: -> @viewData or {}

  # May be overridden
  onPageBeforeShow: ->
    console.log("View #{@constructor.name}: onPageBeforeShow")
    return

  # May be overridden
  # Called after page was created in DOM but before jQM enhancements
  onPageCreate: ->
    if @needsScreenSizeEvents
      crossPlatform = require('lib/cross_platform')
      crossPlatform.addScreenSizeChangeCallback(this, (crossPlatform) => @onScreenSizeChanged(crossPlatform))

    console.log("View #{@constructor.name}: onPageCreate")
    return

  # May be overridden
  onPageHide: ->
    console.log("View #{@constructor.name}: onPageHide")
    return

  # May be overridden
  onPageRemove: ->
    if @needsScreenSizeEvents
      crossPlatform.removeScreenSizeChangeCallback(this)

    console.log("View #{@constructor.name}: onPageRemove")
    return

  # Will only be called if @needsScreenSizeEvents is true. Use crossPlatform (instance of 'lib/cross_platform') to
  # determine the current size and aspect ratio.
  onScreenSizeChanged: (crossPlatform) ->
    return

  render: ->
    console.log("Rendering #{@constructor.name}")
    viewData = @getViewData()

    # Only log if non-empty view data object
    for key of viewData
      console.log("View data is #{JSON.stringify(viewData)}")
      break

    html = @template(viewData)

    @$el = $(document.createElement('div'))
    @$el.html(html)
    @afterRender()
    console.log "Finished rendering #{@constructor.name}"

    @

  setViewData: (viewData) ->
    @viewData = viewData

  # This must be overwritten
  template: ->
    console.log("View class #{@constructor.name} does not overwrite template method")

  translate: ->
    # Use i18next library to translate any HTML elements marked with the data-i18n attribute (see
    # http://jamuhl.github.com/i18next/)
    @$el.i18n()