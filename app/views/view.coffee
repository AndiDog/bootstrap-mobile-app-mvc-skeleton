crossPlatform = require('lib/cross_platform')

# Base class for all views.
module.exports = class View extends Backbone.View
  afterRender: ->
    # Turn it into a jQM page
    # If the template already defines a JQM page, use it
    existingPage = @$el.find('[data-role="page"]')

    if existingPage.length > 1
      throw 'Expected exactly 0 or 1 JQM pages'
    else if existingPage.length is 0
      if @$el.length isnt 1
        throw "Template of #{@constructor.name} must have a top-level element (usually a DIV)"

      @$el.attr('data-role', 'page')
      existingPage = @$el

    # Default to theme A, must be applied before page gets enhanced by jQM
    if not existingPage.attr('data-theme')
      existingPage.attr('data-theme', 'a')

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
    console.log("View #{@constructor.name}: onPageCreate")
    return

  # May be overridden
  onPageHide: ->
    console.log("View #{@constructor.name}: onPageHide")
    return

  # May be overridden
  onPageRemove: ->
    console.log("View #{@constructor.name}: onPageRemove")
    return

  render: ->
    console.log("Rendering #{@constructor.name}")
    viewData = @getViewData()

    # Only log if non-empty view data object
    for key of viewData
      console.log("View data is #{JSON.stringify(viewData)}")
      break

    html = @template(viewData)

    if crossPlatform.isWeb()
      # Get the currently selected tab
      tabTag = hist.getCurrentQueueName()

      # Not the best way to add a tab bar, but it works somehow. The currently selected tab is not always correct,
      # though :( (TODO). This also only works if the template does not contain a DIV with data-role="page" yet because
      # else the appended part is not displayed.
      html += "<div data-role='footer' data-id='web-target-toolbar' data-position='fixed'>
                   <div data-role='navbar'>
                       <ul>
                           <li><a #{if tabTag is 'tab-home' then 'class="ui-btn-active ui-state-persist"' else ''} onclick='javascript:require(\"mediator\").trigger(\"tab-changed\", \"tab-home\");return false;'>Home</a></li>
                           <li><a #{if tabTag is 'tab-settings' then 'class="ui-btn-active ui-state-persist"' else ''} onclick='javascript:require(\"mediator\").trigger(\"tab-changed\", \"tab-settings\");return false;'>Settings</a></li>
                       </ul>
                   </div>
               </div>
               <script>
                   function webTabChange(tabTag)
                   {
                       require('mediator').trigger('tab-changed', tabTag)
                   }
               </script>"

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
    # You may want to comment this in if you use the i18next library (very recommended, see
    # http://jamuhl.github.com/i18next/)
    #@$el.i18n()
    return