# Note that if you remove the following line, you will get "No Transport" errors from jQuery in application code because
# it does not have a valid XHR constructor.
needjQueryAjaxForUnitTests(require)

describe 'Unit tests', ->
  it 'must allow application code to run jQuery AJAX requests (CORS)', (done) ->
    @timeout(2500)

    require('lib/ajax')(done)