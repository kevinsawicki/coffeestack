fs = require 'fs'
CoffeeScript = require 'coffee-script'
{SourceMapConsumer} = require 'source-map'

convertLine = (filePath, line, column) ->
  code = fs.readFileSync(filePath, 'utf8')
  compiled = CoffeeScript.compile(code, {sourceMap: true, filename: filePath})
  sourceMap = new SourceMapConsumer(compiled.v3SourceMap)
  position = sourceMap.originalPositionFor({line, column})
  if position.line? and position.column?
    {line: position.line, column: position.column}
  else
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
        convertedLines.push("#{match[1]}(#{filePath}:#{mappedLine.line}:#{mappedLine.column})")
      else
        convertedLines.push(line)
    else
      convertedLines.push(line)

  convertedLines.join('\n')

module.exports = {convertLine, convertStackTrace}
