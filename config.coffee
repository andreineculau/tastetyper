pkg = require './package.json'

module.exports = {
  # backend-only vars
  pkg
  listenOn: [
    protocol: 'http'
    module: 'http'
    hostname: '0.0.0.0'
    port: 3000
    options: undefined     # options for module.createServer
    headers:               # extra headers
      'Cache-Control': 'no-cache, no-store, must-revalidate'
      'Pragma': 'no-cache'
      'Expires': '0'
      'Server': "#{pkg.name}/#{pkg.version}"
  ],
  subpath: '/'             # host tastebin under a subpath
  tastesDir: 'tastes'      # where are tastes stored
  maxSize: '128kb'         # allow only tastes smaller than 128 kilobytes
  maxFilenameLength: 256   # allow tastes to have maximum 256 characters
  morgan:                  # logging https://github.com/expressjs/morgan
    format: 'common'

  # backend & frontend vars
  title: "#{pkg.name}/#{pkg.version}"
  newTaste: [              # content for the "new taste" page
    'A. \#{metaKeyName}+E to Edit'
    'B. \#{metaKeyName}+S to Save'
    '   \#{metaKeyName}+Shift+S to Save As'
    'C. Esc to cancel editing'
  ].join '\n'
  stylesheets: ''             # extra stylesheets
  scripts: ''                 # extra scripts
  theme: 'index'              # default theme
  themes: [                   # available themes
    'index'
  ]
  hljsStyle: 'solarized_dark' # default style
  hljsStyles: undefined       # restrict available styles
}
