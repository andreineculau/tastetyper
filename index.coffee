fs = require 'fs'
debug = require('debug') 'tastetyper'
express = require 'express'
morgan = require 'morgan'
serveStatic = require 'serve-static'
rawBody = require 'raw-body'
mediaTyper = require 'media-typer'
execFile = require('child_process').execFile

module.exports = exports = (config = {}) ->
  config.hljsStylesHtml = ['\n']
  for hljsStyle in config.hljsStyles
    selected = ''
    selected = ' selected'  if hljsStyle is config.hljsStyle
    config.hljsStylesHtml.push "<option#{selected} value=\"#{hljsStyle}\">#{hljsStyle}</option>\n"
  config.hljsStylesHtml = config.hljsStylesHtml.join ''

  app = express.Router({strict: true})
  {saveFile} = exports

  app.use morgan config.morgan.format

  app.get '/', (req, res, next) ->
    res.render 'index', {config}

  app.use '/tastes', serveStatic config.tastesDir
  app.use serveStatic 'static'
  app
