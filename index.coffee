fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'
{SourceMapConsumer} = require 'source-map'

convertLine = (filePath, line, column, sourceMaps={}) ->
  try
    unless sourceMapContents = sourceMaps[filePath]
      if path.extname(filePath) is '.js'
        sourceMapPath = "#{filePath}.map"
        sourceMapContents =  fs.readFileSync(sourceMapPath, 'utf8')
      else
        code = fs.readFileSync(filePath, 'utf8')
        {v3SourceMap} = CoffeeScript.compile(code, {sourceMap: true, filename: filePath})
        sourceMapContents = v3SourceMap

    if sourceMapContents
      sourceMaps[filePath] = sourceMapContents
      sourceMap = new SourceMapConsumer(sourceMapContents)
      position = sourceMap.originalPositionFor({line, column})
      if position.line? and position.column?
        if position.source
          source = path.resolve(filePath, '..', position.source)
        else
          source = filePath
        return {line: position.line, column: position.column, source}

  null

convertStackTrace = (stackTrace, sourceMaps={}) ->
  return stackTrace unless stackTrace

  convertedLines = []
  atLinePattern = /^(\s+at .* )\((.*):(\d+):(\d+)\)/
  for stackTraceLine in stackTrace.split('\n')
    if match = atLinePattern.exec(stackTraceLine)
      filePath = match[2]
      line = match[3]
      column = match[4]
      if path.extname(filePath) is '.js'
        mappedLine = convertLine(filePath, line, column, sourceMaps)
      if mappedLine?
        convertedLines.push("#{match[1]}(#{mappedLine.source}:#{mappedLine.line}:#{mappedLine.column})")
      else
        convertedLines.push(stackTraceLine)
    else
      convertedLines.push(stackTraceLine)

  convertedLines.join('\n')

module.exports = {convertLine, convertStackTrace}
