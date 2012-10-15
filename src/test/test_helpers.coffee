# This file is automatically used by the test runner of Brunch and exposes chai's expect/assert objects globally in all
# unit test specifications.
chai = require('chai')
node$ = require('jquery')
XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest

module.exports =
  expect: chai.expect,
  assert: chai.assert,
  node$: node$,

  # Can be called from a test spec to modify jQuery in a way that CORS requests can be made in a unit test environment.
  # The require parameter is the require function as used in the application part, while the above require represents
  # the one that is only available in this very file and will load Node modules instead of application moduels!
  needjQueryAjaxForUnitTests: (require) ->
    if not require
      throw 'Must pass require function'

    app$ = require('lib/test_glue').getjQuery()
    app$.support.cors = true
    app$.ajaxSettings.xhr = ->
      return new XMLHttpRequest()