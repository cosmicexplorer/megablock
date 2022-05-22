fs = require 'fs'
path = require 'path'
{promisify} = require 'util'

glob = promisify require 'glob'
rimraf = promisify require 'rimraf'
CoffeeScript = require 'coffeescript'

compileCoffee = (coffeePath) ->
  input = await promisify(fs.readFile) coffeePath, encoding: 'utf8'
  jsPath = coffeePath.replace /\.coffee$/, '.js'
  console.log "compiling #{coffeePath} to #{jsPath}..."
  output = CoffeeScript.compile input,
    inlineMap: yes
    bare: yes
    header: yes
  await promisify(fs.writeFile) jsPath, output
  jsPath

task 'build:coffee', 'compile .coffee files', ->
  for appSource in await glob '**/*.coffee'
    await compileCoffee appSource
