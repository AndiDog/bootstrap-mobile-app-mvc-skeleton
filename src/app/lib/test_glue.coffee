# Module for accessing objects of the application from unit tests in order to change their behavior (e.g. allow CORS
# AJAX requests when running in unit test environment).
module.exports =
  getjQuery: ->
    return $