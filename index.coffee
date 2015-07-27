fs = require 'fs'
debug = require('debug') 'tastetyper'
express = require 'express'
morgan = require 'morgan'
serveStatic = require 'serve-static'
rawBody = require 'raw-body'
mediaTyper = require 'media-typer'
execFile = require('child_process').execFile

module.exports = exports = (config = {}) ->
  config.stylesHtml = ['\n']
  for style in config.styles
    selected = ''
    selected = ' selected'  if style is config.style
    config.stylesHtml.push "<option#{selected} value=\"#{style}\">#{style}</option>\n"
  config.stylesHtml = config.stylesHtml.join ''

  app = express.Router({strict: true})
  {saveFile} = exports

  app.use morgan config.morgan.format

  app.get '/', (req, res, next) ->
    res.render 'index', {config}

  app.use '/tastes', serveStatic config.tastesDir
  app.use serveStatic 'static'
  app
