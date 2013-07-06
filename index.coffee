fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'
{SourceMapConsumer} = require 'source-map'

convertLine = (filePath, line, column) ->
  try
    sourceMapContents = null
    if path.extname(filePath) is '.js'
      sourceMapPath = path.join(path.dirname(filePath), "#{path.basename(filePath, '.js')}.map")
      sourceMapContents =  fs.readFileSync(sourceMapPath, 'utf8')
    else
      code = fs.readFileSync(filePath, 'utf8')
      {v3SourceMap} = CoffeeScript.compile(code, {sourceMap: true, filename: filePath})
      sourceMapContents = v3SourceMap

    if sourceMapContents
      sourceMap = new SourceMapConsumer(sourceMapContents)
      position = sourceMap.originalPositionFor({line, column})
      if position.line? and position.column?
        if position.source
          source = path.resolve(filePath, '..', position.source)
        else
          source = filePath
        return {line: position.line, column: position.column, source}

  null

convertStackTrace = (stackTrace) ->
  return stackTrace unless stackTrace

  convertedLines = []
  atLinePattern = /^(\s+at .* )\((.*):(\d+):(\d+)\)/
  for line in stackTrace.split('\n')
    if match = atLinePattern.exec(line)
      filePath = match[2]
      line = match[3]
      column = match[4]
      if mappedLine = convertLine(filePath, line, column)
        convertedLines.push("#{match[1]}(#{mappedLine.source}:#{mappedLine.line}:#{mappedLine.column})")
      else
        convertedLines.push(line)
    else
      convertedLines.push(line)

  convertedLines.join('\n')

module.exports = {convertLine, convertStackTrace}
