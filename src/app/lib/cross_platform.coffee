ASPECT_RATIO_QUERY = '(orientation: landscape)'
SIZE_QUERY = 'screen and (min-width: 16cm)'

# Platfrom detection, should work before and after PhoneGap is loaded
class CrossPlatform
  # Target

  isAndroid: ->
    return window.appTarget is 'android' or (window.device and device.platform is 'Android')

  isiOS: ->
    return window.appTarget is 'ios' or (window.device and device.platform is 'iPhone' or device.platform is 'iPad')

  isWeb: ->
    return window.appTarget is 'web'

  # Display

  screenSizeChangeCallbacks = null

  addScreenSizeChangeCallback: (identifier, callback) ->
    if not @screenSizeChangeCallbacks
      @screenSizeChangeCallbacks = []

      @screenSizeChangeHandlerSize =
        match: => @onScreenSizeChanged(true, null)
        unmatch: => @onScreenSizeChanged(false, null)
      @screenSizeChangeHandlerAspectRatio =
        match: => @onScreenSizeChanged(null, true)
        unmatch: => @onScreenSizeChanged(null, false)

      # When first callback is added, register listener
      enquire.register(SIZE_QUERY, @screenSizeChangeHandlerSize)
             .register(ASPECT_RATIO_QUERY, @screenSizeChangeHandlerAspectRatio)
             .listen(400)

    @screenSizeChangeCallbacks.push([identifier, callback])

  isLandscapeOrientation: ->
    return @isLandscapeAspectRatio

  isTablet: ->
    return @isTabletScreenSize

  onScreenSizeChanged: (tabletSizeMatches, landscapeAspectRatioMatches) ->
    if tabletSizeMatches isnt null
      console.debug("Screen size changed: #{if tabletSizeMatches then 'tablet' else 'phone'}")
      @isTabletScreenSize = tabletSizeMatches
    if landscapeAspectRatioMatches isnt null
      console.debug("Screen aspect ratio changed: #{if landscapeAspectRatioMatches then 'landscape' else 'portrait'}")
      @isLandscapeAspectRatio = landscapeAspectRatioMatches

    if not @screenSizeChangeCallbacks
      console.log('Assertion error: onScreenSizeChanged registered but no callbacks')
      return

    for item in @screenSizeChangeCallbacks
      item[1](this)

  removeScreenSizeChangeCallback: (identifier, callback) ->
    found = false

    if @screenSizeChangeCallbacks
      for i in [0...@screenSizeChangeCallbacks.length]
        if @screenSizeChangeCallbacks[i][0] is identifier
          found = true

          # Remove item
          @screenSizeChangeCallbacks.splice(i, 1)

    if not found
      console.log('removeScreenSizeChangeCallback failed to find callback, possible memory hog')
      return

    if @screenSizeChangeCallbacks.length is 0
      @screenSizeChangeCallbacks = null

      enquire.unregister(SIZE_QUERY, @screenSizeChangeHandlerSize)
      enquire.unregister(ASPECT_RATIO_QUERY, @screenSizeChangeHandlerAspectRatio)

      @screenSizeChangeHandlerSize = null
      @screenSizeChangeHandlerAspectRatio = null

module.exports = new CrossPlatform()