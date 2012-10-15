# This is only an example to show that the unit test environment allows application code to run CORS AJAX requests.
# See test/ajax_test.coffee
module.exports = (done) ->
  $.ajax
    url: 'http://www.google.com/',
    success: (response) ->
      done()
    error: (jqXHR, textStatus, errorThrown) ->
      done(errorThrown)