# Handles history of loaded jQM pages in one or more "queues" and correct insertion/switches of pages in the DOM.
# One queue could be one tab, for example.
class History
  constructor: ->
    @currentQueueName = null
    @queues = {}

  canPop: (queueName=null) ->
    queueName ?= @currentQueueName

    queue = @queues[queueName]
    return queue.length > 1

  getCurrentQueueName: -> @currentQueueName

  getLastQueueEntry: (queueName) ->
    queue = @queues[queueName]

    if queue.length is 0
      return null

    return queue.slice(-1)[0]

  # Usually called from within a view template in order to close the current screen (e.g. back button pressed)
  pop: (options={}) ->
    queueName = options.queueName or @currentQueueName

    queue = @queues[queueName]
    if queue.length <= 1
      throw "Cannot pop a view from queue #{queueName} because there is only #{queue.length} view left"

    queueEntryDepth = queue.length - 1

    queueEntryToRemove = queue.pop()
    queueEntryToShowNow = queue.slice(-1)[0]

    # When popping a screen, use the same transition as used for pushing it, but reversed
    # Note: Cloning actually wouldn't be necessary since we will discard the options object anyway, but it might be a
    #       good idea to keep it for debugging purposes.
    defaultOptions = _.clone(queueEntryToRemove.options)
    if 'transition' of defaultOptions and 'reverse' of defaultOptions
      defaultOptions.reverse = not defaultOptions.reverse

    @_switchTo(queueEntryToShowNow.el, queueEntryDepth, $.extend({reverse: true}, defaultOptions, options))

    setTimeout (->
      # Unload popped view from DOM
      queueEntryToRemove.el.remove()
    ), 3000

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

    if queue.length > 0 and queue.slice(-1)[0].fragment is fragment
      console.log("Not replacing fragment #{fragment}, already loaded")
      return

    if options.replace
      # Clear queue
      queue = []
      @queues[queueName] = queue

    queueEntryDepth = queue.length
    queueEntry = {fragment: fragment, options: {}}

    # Store other parameters if existent, may be necessary later on (e.g. for popping)
    if 'transition' of options
      queueEntry.options.transition = options.transition
    if 'reverse' of options
      queueEntry.options.reverse = options.reverse

    queue.push(queueEntry)

    mediator.trigger 'must-load-fragment', fragment, queueName, (view) =>
      el = view.getHtmlElement()
      el.attr('data-queue', queueName)
      el.attr('data-queue-entry-depth', queueEntryDepth)
      queueEntry.el = el
      queueEntry.view = view

      setTimeout (=>
        $('body').append(el)

        if @currentQueueName is queueName
          @_switchTo(el, queueEntryDepth, options)
      ), 0

  registerQueue: (queueName) ->
    @queues[queueName] = []

  replace: (fragment, options={}) ->
    @push(fragment, $.extend(options, {replace: true}))

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

  setCurrentQueueName: (queueName) ->
    if queueName not of @queues
      throw "Queue #{queueName} unregistered"

    @currentQueueName = queueName

  _switchTo: (page, queueEntryDepth, options={}) ->
    if not page
      throw 'page is undefined, must be a jQM page'

    if page.attr('data-role') isnt 'page'
      jQMPages = page.find('[data-role="page"]')
      if jQMPages.length isnt 1
        throw 'page does not contain any jQM page (with attribute data-role=page)'
      page = jQMPages

    defaultTransition = 'slide'
    if queueEntryDepth is 0
      defaultTransition = 'none'
    if options.replace
      defaultTransition = 'fade'

    settings = $.extend({transition: defaultTransition, changeHash: false}, options)
    $.mobile.changePage(page, settings)

    # Ensure jQM enhancements
    page.trigger('create')

    # We don't keep track of the location hash, but here would be the place to change it

module.exports = new History()