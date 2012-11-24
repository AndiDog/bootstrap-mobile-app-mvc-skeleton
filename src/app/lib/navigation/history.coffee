# Handles history of loaded pages in one or more "queues" and correct insertion/switches of pages in the DOM.
# One queue could be one tab, for example.
class History
  defaultTransitionDuration: 500

  constructor: ->
    @currentQueueName = null
    @queues = {}

  _afterTransition: ->
    window.scrollTo(0, 0)
    $(':focus').blur()

  canPop: (queueName=null) ->
    queueName ?= @currentQueueName

    queue = @queues[queueName]
    return queue.length > 1

  _findActivePageAndView: (ifInQueueNamed) ->
    fromPage = $('body > .page-container > .active-page[data-queue="' + ifInQueueNamed + '"]')
    if fromPage.length is 0
      return [null, null]
    else
      fromView = @_findViewForElement(fromPage[0])

      return [fromPage, fromView]

  _findViewForElement: (htmlEl) ->
    if htmlEl.jquery
      throw 'Must pass pure HTML element'

    hasQueueEntries = false

    for queueName, queue of @queues
      hasQueueEntries ||= queue.length isnt 0
      if queue.length isnt 0 and queue[queue.length-1].el[0] is htmlEl
        return queue[queue.length-1].view
      else if queue.length > 1 and queue[queue.length-2].el[0] is htmlEl
        # When a view was pushed, the sought view may be at second level
        return queue[queue.length-2].view

    console.error("View for element #{htmlEl} not found (hasQueueEntries=#{hasQueueEntries})")
    return null

  getCurrentQueueName: -> @currentQueueName

  getLastQueueEntry: (queueName=null, butOne=false) ->
    queueName ?= @currentQueueName

    queue = @queues[queueName]

    if queue.length < (if butOne then 2 else 1)
      return null

    return queue.slice((if butOne then -2 else -1))[0]

  # Usually called from within a view template in order to close the current screen (e.g. back button pressed)
  pop: (options={}) ->
    queueName = options.queueName or @currentQueueName

    queue = @queues[queueName]
    if queue.length <= 1
      throw "Cannot pop a view from queue #{queueName} because there is only #{queue.length} view left"

    # Must find previous view before it may get removed in the code below
    fromPageAndView = @_findActivePageAndView(queueName)

    queueEntryDepth = queue.length - 1

    queueEntryToRemove = queue.pop()
    queueEntryToShowNow = queue.slice(-1)[0]

    # When popping a screen, use the same transition as used for pushing it, but reversed
    # Note: Cloning actually wouldn't be necessary since we will discard the options object anyway, but it might be a
    #       good idea to keep it for debugging purposes.
    defaultOptions = _.clone(queueEntryToRemove.options)
    if 'transition' of defaultOptions and 'reverse' of defaultOptions
      defaultOptions.reverse = not defaultOptions.reverse

    @_switchTo(queueEntryToShowNow.el,
               queueEntryDepth,
               queueEntryDepth + 1,
               $.extend({reverse: true}, defaultOptions, options),
               fromPageAndView[0],
               fromPageAndView[1])

    setTimeout (=> @_unloadQueueEntry(queueEntryToRemove)), 3000

  popView: (view) ->
    if not view.findHtmlElement
      throw 'Not a view'

    for queueName, queue of @queues
      for queueEntry in queue.slice(-1)
        if not queueEntry.view
          throw 'Assertion failed (view instance must be stored in queue)'

        if queueEntry.view is view
          @pop({queueName: queueName})
          return

  # Prefetches the very first page in a queue (use push otherwise!)
  prefetch: (fragment, queueName) ->
    setTimeout (=>
      @push(fragment, {queueName: queueName})
    ), 0

  # Can be called manually from debug console
  printDebugInfo: ->
    console.log("History state @ #{new Date()}")
    console.log('-------------')
    for queueName, queue of @queues
      for i in [0...queue.length]
        queueEntry = queue[i]

        fragmentStr = if queueEntry.fragment.length is 0 then '<empty fragment (start page)>' else queueEntry.fragment

        if i < queue.length - 1
          console.log("#{fragmentStr} -> ")
        else
          # Current top view
          console.log("*#{fragmentStr}*")
    console.log('-------------')

  push: (fragment, options={}) ->
    queueName = options.queueName or @currentQueueName
    options.replace ?= false

    queue = @queues[queueName]

    if fragment and queue.length > 0 and queue.slice(-1)[0].fragment is fragment and not options.replace
      console.log("Not replacing fragment #{fragment}, already loaded")
      return

    # See docs of _switchTo parameters
    fromPageAndView = [null, null]

    if options.replace
      # Must determine previous page and view before top queue entry is removed
      fromPageAndView = @_findActivePageAndView(queueName)

      if queue.length is 0
        throw new Error 'Queue is empty, cannot replace any view'

      # Remove queue entry that is about to be replaced
      queueEntryToRemove = queue.pop()
    else
      queueEntryToRemove = null

    queueEntryDepth = queue.length + 1
    queueEntry = {fragment: fragment, options: {}}

    # Scenario: Main screen --slide--> choose date --replace,default(fade)--> results screen
    # In that case, when the results screen calls pop, we want to use the slide transition!
    if options.replace
      if 'transition' of queueEntryToRemove.options
        queueEntry.options.transition = queueEntryToRemove.options.transition
      if 'reverse' of queueEntryToRemove.options
        queueEntry.options.reverse = queueEntryToRemove.options.reverse

    # Store other parameters if existent, may be necessary later on (e.g. for popping)
    if 'transition' of options
      queueEntry.options.transition = options.transition
    if 'reverse' of options
      queueEntry.options.reverse = options.reverse

    currentQueueLength = queue.length

    onViewLoaded = (view) =>
      # Insert at right place
      queue.splice(currentQueueLength, 0, queueEntry)

      el = view.getHtmlElement()

      el.attr('data-queue', queueName)

      # Add debugging attribute
      el.attr('data-queue-entry-depth', queueEntryDepth)

      queueEntry.el = el
      queueEntry.view = view

      setTimeout (=>
        $('body > .page-container').append(el)
        try
          queueEntry.view.onPageCreate()
        catch e
          console.error("Error in onPageCreate: #{e}")

        if @currentQueueName is queueName
          @_switchTo(el, queueEntryDepth, queueEntryDepth - 1, options, fromPageAndView[0], fromPageAndView[1])

        if queueEntryToRemove?
          setTimeout (=> @_unloadQueueEntry(queueEntryToRemove)), 5000
      ), 0

    if 'loadedView' of options
      if not options.loadedView.getHtmlElement()
        throw "View is not rendered (view=#{options.loadedView})"

      onViewLoaded(options.loadedView)
    else
      mediator.trigger('must-load-fragment', fragment, queueName, onViewLoaded)

  # Assumes that view is rendered
  pushByView: (loadedView, fragment, options={}) ->
    @push(fragment, $.extend({}, options, {loadedView: loadedView}))

  registerQueue: (queueName) ->
    @queues[queueName] = []

  replace: (fragment, options={}) ->
    @push(fragment, $.extend({}, options, {replace: true}))

  # Replaces top view by the given view and assigns the fragment to it
  replaceByView: (loadedView, fragment, options={}) ->
    if not loadedView.findHtmlElement
      throw 'Not a view'

    if not fragment
      throw 'Must specify fragment for loaded view'

    @push(fragment, $.extend({}, options, {loadedView: loadedView, replace: true}))

  # Replaces the specified view by the view loaded using the given fragment
  replaceView: (view, fragment) ->
    if not view.findHtmlElement
      throw 'Not a view'

    for queueName, queue of @queues
      for queueEntry in queue.slice(-1)
        if not queueEntry.view
          throw 'Assertion failed (view instance must be stored in queue)'

        if queueEntry.view is view
          @push(fragment, {queueName: queueName, replace: true})
          return

  # Sets current queue name without any DOM changes
  setCurrentQueueName: (queueName) ->
    if queueName not of @queues
      throw "Queue #{queueName} unregistered"

    @currentQueueName = queueName

  # Transitions to another queue
  switchQueue: (queueName, options={}) ->
    if @currentQueueName is queueName
      console.warn("Same-queue transition #{queueName}")
      return

    toQueue = @queues[queueName]
    if toQueue.length is 0
      throw "No (prefetched) page in queue #{queueName}"

    toPage = toQueue.slice(-1)[0].el
    queueEntryDepth = toQueue.length

    @_switchTo(toPage, queueEntryDepth, queueEntryDepth, options)
    @currentQueueName = queueName

  # Parameters fromPage/fromView must be null if the active view (the one which should be hidden) should be searched by
  # this method (and not predetermined earlier). This is important for replace/pop because the previous view may not be
  # found anymore since it has been popped from its queue.
  # queueEntryDepth represents the number of queue entries the active queue will have after this transition. For example,
  # if a second view is pushed over the main view, it must be 2.
  _switchTo: (page, queueEntryDepth, previousQueueEntryDepth, options={}, fromPage=null, fromView=null) ->
    if not page
      throw 'page is undefined'
    if fromView? and not fromPage?
      # Assumption: fromView != null ==> fromPage != null (because if an active DOM element fromPage was found, fromView
      #             can be found or not)
      throw 'Assertion error'

    defaultTransition = 'slide'
    if queueEntryDepth is 1 and previousQueueEntryDepth is 0
      # First screen added to queue, do not animate
      defaultTransition = 'none'
    if options.replace
      defaultTransition = 'fade'

    settings = $.extend({transition: defaultTransition}, options)

    if not fromView?
      fromPage = $('body > .page-container > .active-page') # may be empty at first call
      fromView = if fromPage.length is 0 then null else @_findViewForElement(fromPage[0])

    toView = @_findViewForElement(page[0])

    try
      fromView?.onPageHide()
    catch e
      console.error("Error in onPageHide: #{e}")

    try
      toView?.onPageBeforeShow()
    catch e
      console.error("Error in onPageBeforeShow: #{e}")

    fromPage.each (el) ->
      if page[0] is el
        throw 'Assertion error: Trying to switch to self'

    if page.hasClass('active-page')
      # This can only happen if the user clicks fast enough to trigger a switch when another one is still running (i.e.
      # an animation is active). Stop it first.
      $('body > .page-container > .page').stop()

    switch settings.transition
      when 'none' then @_transitionNone(fromPage, page, settings)
      when 'fade' then @_transitionFade(fromPage, page, settings)
      when 'slide' then @_transitionSlide(fromPage, page, settings)
      when 'slidedown' then @_transitionSlideDown(fromPage, page, settings)
      else console.error("Unknown transition type '#{settings.transition}'")

    # We don't keep track of the location hash, but here would be the place to change it

  _transitionNone: (fromPage, toPage, options) ->
    width = window.innerWidth

    fromPage.removeClass('active-page')
    fromPage.css('left', -width)
    fromPage.css('opacity', 0)

    toPage.addClass('active-page')
    toPage.css('left', 0)
    toPage.css('opacity', 1)

    @_afterTransition()

  _transitionFade: (fromPage, toPage, options) ->
    settings = $.extend({duration: @defaultTransitionDuration}, options)

    if fromPage
      fromPage.stop().animate {opacity: 0}, settings.duration/2, ->
        fromPage.removeClass('active-page')
        fromPage.css('left', '0')
        fromPage.css('opacity', '1')

    toPage.css('left', 0)
    toPage.css('opacity', 0)
    toPage.addClass('active-page')
    toPage.stop().animate({opacity: 1}, settings.duration, => @_afterTransition())

  _transitionSlide: (fromPage, toPage, options) ->
    settings = $.extend({duration: @defaultTransitionDuration}, options)
    width = window.innerWidth

    if fromPage
      fromPage.stop().animate {left: (if settings.reverse then 1 else -1) * width, opacity: 0}, settings.duration, ->
        fromPage.removeClass('active-page')
        fromPage.css('left', '0')
        fromPage.css('opacity', '1')

    toPage.css('left', (if settings.reverse then -1 else 1) * width)
    toPage.css('opacity', 0)
    toPage.addClass('active-page')
    toPage.stop().animate({left: 0, opacity: 1}, settings.duration, => @_afterTransition())

  _transitionSlideDown: (fromPage, toPage, options) ->
    settings = $.extend({duration: @defaultTransitionDuration}, options)
    height = window.innerHeight

    if fromPage
      fromPage.stop().animate {opacity: 0}, settings.duration/2
      fromPage.animate {top: (if settings.reverse then -1 else 1) * height}, settings.duration, ->
        fromPage.removeClass('active-page')
        fromPage.css('top', '0')
        fromPage.css('opacity', '1')

    toPage.css('opacity', '0')
    toPage.css('top', (if settings.reverse then 1 else -1) * height)
    toPage.addClass('active-page')
    toPage.stop().animate {top: 0, opacity: 1}, settings.duration, =>
      @_afterTransition()

  _unloadQueueEntry: (queueEntry) ->
    # Unload popped view from DOM
    try
      queueEntry.view.onPageRemove()
    catch e
      console.error("Error in onPageRemove: #{e}")

    queueEntry.el.remove()

module.exports = new History()