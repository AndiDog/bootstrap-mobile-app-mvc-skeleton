$(document).bind("mobileinit",function(){
    $.mobile.ajaxEnabled = false
    $.mobile.hashListeningEnabled = false
    $.mobile.linkBindingEnabled = false
    $.mobile.pushStateEnabled = false

    $('div[data-role="page"]').live('pagehide', function(event, ui) {
        $(event.currentTarget).remove()
    })
})