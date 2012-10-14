describe 'Views', ->
  it 'must have page event methods like onPageBeforeShow', (done) ->
    View = require('views/view')
    assert.isFunction(View.prototype.onPageBeforeShow)
    assert.isFunction(View.prototype.onPageCreate)
    assert.isFunction(View.prototype.onPageHide)
    assert.isFunction(View.prototype.onPageRemove)
    done()