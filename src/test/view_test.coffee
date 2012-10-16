describe 'Views', ->
  it 'must have page event methods like onPageBeforeShow', (done) ->
    View = require('views/view')
    assert.isFunction(View::onPageBeforeShow)
    assert.isFunction(View::onPageCreate)
    assert.isFunction(View::onPageHide)
    assert.isFunction(View::onPageRemove)
    done()