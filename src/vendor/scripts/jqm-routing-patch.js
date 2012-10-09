// This file MUST be placed before the jQuery Mobile script, or else the mobileinit callback is not called

// http://andidog.de/blog/2012/06/using-jquery-mobile-with-backbone-how-to-solve-routing-conflicts-and-use-mvc-for-the-application/
$(document).bind('mobileinit', function() {
    $.mobile.ajaxEnabled = false
    $.mobile.hashListeningEnabled = false
    $.mobile.linkBindingEnabled = false
    $.mobile.pushStateEnabled = false
})