View = require('./view')

module.exports = class SidebarView extends View
  needsScreenSizeEvents: true

  afterRender: ->
    # Allow to use two DIVs in our page, cannot change it later because history module references the top element after
    # a view is completely rendered
    mainView = @$el
    @$el = $(document.createElement('div'))
    @$el.append(mainView)

    super

  onPageBeforeShow: ->
    super

    @onScreenSizeChanged(require('lib/cross_platform'))

  onPageHide: ->
    super

    if @sidebarLoaded
      @sidebar.css('display', 'none')

  onScreenSizeChanged: (crossPlatform) ->
    if crossPlatform.isLandscapeOrientation() and crossPlatform.isTablet()
      @showSidebar()
    else
      @hideSidebar()

  hideSidebar: ->
    if not @sidebarLoaded
      return

    mainView = @$el.children(':first')

    @sidebar.css('display', 'none')
    mainView.removeClass('sidebar-main')

  showSidebar: ->
    mainView = @$el.children(':first')

    if @sidebarLoaded
      @sidebar.css('display', 'block')
      mainView.addClass('sidebar-main')
      return

    @sidebar = $(@renderSidebar())
    @sidebar.addClass('sidebar')
    mainView.addClass('sidebar-main')

    @sidebar.css('display', 'block')
    mainView.css('display', 'block')

    $('body').append(@sidebar)

    @sidebarLoaded = true