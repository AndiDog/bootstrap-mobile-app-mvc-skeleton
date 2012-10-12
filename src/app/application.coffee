Application =
  initialize: ->
    # Expose global 'hist' object for navigation purposes
    window.hist = require('lib/navigation/history')

    @initTranslations()
    @initControllers()
    @initNavigation()

    @initWithPhoneGap()

    # Freeze the object
    Object.freeze? this

  initControllers: ->
    # Instantiate the controllers that may be needed at application startup. You can as well just load all of them if
    # you wish. Since controllers register routes in their constructor, a controller must be loaded before a certain
    # route is accessed.
    mediator = require('mediator')
    mediator.requireController('controllers/home')
    mediator.requireController('controllers/settings')

  initNavigation: ->
    # Set up tabs
    hist.registerQueue('tab-home')
    hist.registerQueue('tab-settings')
    hist.setCurrentQueueName('tab-home')

    mediator = require('mediator')
    mediator.subscribe('tab-changed', (tabTag) => @onTabChanged(tabTag))

    # Load first page (note: first parameter is the fragment, e.g. 'home' in 'http://localhost/#home')
    hist.push('route-for-home', {queueName: 'tab-home'})

    # Prefetch other tabs
    hist.prefetch('route-for-settings', 'tab-settings')

  initTranslations: ->
    # TODO: put logic here to decide on the language
    $.i18n.init({
      lng: 'en',
      fallbackLng: 'en',
      ns: 'translation',
      useLocalStorage: false,
      debug: true,
      resGetPath: 'i18n/__lng__/__ns__.json',
      getAsync: false})

    # Underscore.js already uses '_', so make translation a global 't()' function
    window.t = $.t

  initWithPhoneGap: ->
    document.addEventListener 'deviceready', (=>
      console.log('PhoneGap ready')
      mediator = require('mediator')

      crossPlatform = require('lib/cross_platform')

      if crossPlatform.isAndroid()
        actionBarSherlockTabBar = cordova.require('cordova/plugin/actionBarSherlockTabBar')
        actionBarSherlockTabBar.setTabSelectedListener (tabTag) ->
          mediator.trigger('tab-changed', tabTag)

        document.addEventListener('backbutton', (e) ->
          console.log('backbuttonpress')

          e.preventDefault()

          # Exit if back button is pressed on primary screen
          if hist.canPop()
            hist.pop()
          else
            navigator.app.exitApp();
        , false)
      # endif Android

      setTimeout (->
        navigator.splashscreen.hide()
      ), 300
    ), false

  # Since the History class only handles "queues" and itself does not have a notion of "tabs", we add this logic
  # ourselves. This way, the History class remains with a very minimal purpose :)
  onTabChanged: (tabTag) ->
    # This event means another tab was clicked by the user so we have to display the page of that tab
    console.log("Tab changed to #{tabTag}")

    previousTabTag = hist.getCurrentQueueName()
    if previousTabTag is tabTag
      console.log("Tab already active: #{tabTag}")
      return

    existingPages = $('[data-queue="' + tabTag + '"][data-role="page"]')

    if existingPages.length is 0
      throw "No prefetched page on tab #{tabTag}"

    existingPage = hist.getLastQueueEntry(tabTag).el

    if not existingPage
      throw "No page loaded for tab #{tabTag}"

    tabOrder =
      'tab-home': 0
      'tab-settings': 1

    webTabBars = $('[data-id="web-target-toolbar"]')
    # TODO: Still doesn't deselect the previous tab, very unnerving
    webTabBars.removeClass('ui-btn-active')
    webTabBars.find('a[data-tab="' + tabTag + '"]').addClass('ui-btn-active')

    settings = {transition: 'slide', changeHash: false, reverse: tabOrder[tabTag] < tabOrder[previousTabTag]}

    # Transition is strange on Android (tested both 2.3.3 and 4.1) - screen blinks one or two times (maybe related to
    # jQM). Maybe someone else wants to try with this block commented out and report if it works.
    crossPlatform = require('lib/cross_platform')
    if crossPlatform.isAndroid()
      settings.transition = 'none'

    $.mobile.changePage(existingPage, settings)

    hist.setCurrentQueueName(tabTag)

module.exports = Application