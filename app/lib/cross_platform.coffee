# Platfrom detection, should work before and after PhoneGap is loaded
class CrossPlatform
  isAndroid: ->
    return window.appTarget is 'android' or (window.device and device.platform is 'Android')

  isiOS: ->
    return window.appTarget is 'ios' or (window.device and device.platform is 'iPhone' or device.platform is 'iPad')

  isWeb: ->
    return window.appTarget is 'web'

module.exports = new CrossPlatform()