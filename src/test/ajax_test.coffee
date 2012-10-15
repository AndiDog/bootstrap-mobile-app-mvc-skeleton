describe 'Unit tests', ->
  before ->
    # If you remove the following line, you will get "No Transport" errors from jQuery in application code because it
    # does not have a valid XHR constructor. Note that this change will not be reverted (not necessary).
    needjQueryAjaxForUnitTests(require)

  it 'must allow application code to run jQuery AJAX requests (CORS)', (done) ->
    @timeout(2500)

    require('lib/ajax')(done)