fs = require 'fs'
path = require 'path'
{promisify} = require 'util'

glob = promisify require 'glob'
rimraf = promisify require 'rimraf'

CoffeeScript = require 'coffeescript'
sass = require 'sass'

readFile = promisify fs.readFile
writeFile = promisify fs.writeFile

compileString = (inPath, oldExt, newExt, compile) ->
  input = await readFile inPath, encoding: 'utf8'
  outPath = inPath.replace oldExt, newExt
  console.log "compiling #{inPath} to #{outPath}..."
  output = await compile input
  await writeFile outPath, output
  outPath

compileCoffee = (coffeePath) -> await compileString coffeePath, /\.coffee$/, '.js', (input) ->
  await CoffeeScript.compile input,
    inlineMap: yes
    bare: yes
    header: yes

compileSass = (scssPath) -> await compileString scssPath, /\.scss$/, '.css', (input) ->
  {css, sourceMap} = await sass.compileStringAsync input,
    sourceMap: yes
    sourceMapIncludeSources: yes
    style: 'expanded'
  """#{css}

  /*# sourceMappingURL=data:application/json:base64,#{btoa JSON.stringify sourceMap} */
  /*# sourceURL=<anonymous-0> */
  """

task 'build:coffee', 'compile .coffee files', ->
  for coffeePath in await glob '**/*.coffee'
    await compileCoffee coffeePath

task 'build:scss', 'compile .scss files', ->
  for scssPath in await glob '**/*.scss'
    await compileSass scssPath
