fs = require 'fs'
path = require 'path'
debug = require('debug') 'tastetyper'
express = require 'express'
morgan = require 'morgan'
serveStatic = require 'serve-static'
rawBody = require 'raw-body'
mediaTyper = require 'media-typer'
cookieParser = require 'cookie-parser'

module.exports = exports = (config = {}) ->
  defaultTheme = config.theme

  config.hljsStylesHtml = ['\n']
  for hljsStyle in config.hljsStyles
    selected = ''
    selected = ' selected'  if hljsStyle is config.hljsStyle
    config.hljsStylesHtml.push "<option#{selected} value=\"#{hljsStyle}\">#{hljsStyle}</option>\n"
  config.hljsStylesHtml = config.hljsStylesHtml.join ''

  app = express.Router {strict: true}
  {saveFile} = exports

  app.use morgan config.morgan.format

  app.get '/', cookieParser(), (req, res, next) ->
    config.theme = defaultTheme
    config.theme = req.cookies.theme  if req.cookies?.theme in config.themes

    tpl = "#{__dirname}/static/#{config.theme}.mustache"
    unless fs.existsSync tpl
      res.clearCookie 'theme'
      config.theme = defaultTheme
      tpl = "#{__dirname}/static/#{config.theme}.mustache"

    config.themesHtml = ['\n']
    for theme in config.themes
      selected = ''
      selected = ' selected'  if theme is config.theme
      config.themesHtml.push "<option#{selected} value=\"#{theme}\">#{theme}</option>\n"
    config.themesHtml = config.themesHtml.join ''

    res.render tpl, {config}

  app.put /^\/tastes\/(.+)/, (req, res, next) ->
    filename = req.params[0]
    if filename.length > config.maxFilenameLength
      return res.status(414).send()
    if "/#{filename}" isnt path.resolve '/', filename
      return res.status(400).send()
    relPath = "tastes/#{filename}"
    saveFile relPath, config, req, res, (err) ->
      return next err  if err?
      res.status(204).send()

  app.use '/tastes', serveStatic config.tastesDir
  app.use serveStatic 'static'
  app


exports.saveFile = (relPath, config, req, res, next) ->
  contentType = req.headers['content-type']
  encoding = 'utf-8'
  encoding = mediaTyper.parse(contentType).parameters.charset  if contentType?
  rawBody req, {
    length: req.headers['content-length']
    limit: config.maxSize
    encoding
  }, (err, data) ->
    return next err  if err?
    fs.writeFile relPath, data, {encoding}, next
