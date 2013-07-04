module.exports =
class Test
  constructor: ->
    @name = 'Test'

  getName: ->
    'Test'

  fail: ->
    throw new Error('this is an error')

  toString: -> @getName()
