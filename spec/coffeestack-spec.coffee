path = require 'path'
{convertLine, convertStackTrace} = require '../index'

describe 'CoffeeStack', ->
  describe 'convertLine(filePath, line, column)', ->
    it 'returns the line number and column numbers of the CoffeeScript file', ->
      filePath = path.join(__dirname, 'fixtures', 'test.coffee')
      expect(convertLine(filePath, 4, 2)).toEqual {line: 1, column: 0}
      expect(convertLine(filePath, 10, 13)).toEqual {line: 7, column: 4}

    describe 'when a source map exists for the file', ->
      it 'reads the source map instead of generating one', ->
        filePath = path.join(__dirname, 'fixtures', 'js-with-map.js')
        expect(convertLine(filePath, 9, 14)).toEqual {line: 3, column: 17}

  describe 'convertStackTrace(stackTrace)', ->
    it 'maps JavaScript lines to their CoffeeScript lines', ->
      Test = require './fixtures/test.coffee'
      stackTrace = null
      try
        new Test().fail()
      catch error
        stackTrace = error.stack

      stackTrace = stackTrace.split('\n')[0..1].join('\n')
      expect(convertStackTrace(stackTrace)).toBe """
        Error: this is an error
            at Test.module.exports.Test.fail (#{__dirname}/fixtures/test.coffee:10:14)"""
