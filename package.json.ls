name   : \wdts
version: \0.4.1
private: true
engines:
  node: '>=0.10.x'
  npm : '>=1.0.x'
scripts:
  start: 'node boot.js'
dependencies:
  bcrypt                  : \0.7.5
  crypto                  : \0.0.3
  'custom-error-generator': \7.0.0
  express                 : \3.1.1
  'http-status'           : \0.1.8
  lodash                  : \3.5.0
  mongoose                : \3.5.5
  passport                : \0.2.0
  'passport-facebook'     : \1.0.3
  'passport-github'       : \0.1.5
  'passport-google-oauth' : \0.1.5
  shortid                 : \2.0.0
devDependencies:
  brfs                  : \~0.0.9
  browserify            : \~3.24.13
  cacheify              : \~0.4.0
  chai                  : \~1.8.1
  chalk                 : \~0.4.0
  cheerio               : \~0.14.0
  cron                  : \~1.0.3
  exposify              : \~0.1.4
  gaze                  : \~0.6.4
  globule               : \~0.2.0 # TODO: remove when gaze fixes issue 104
  gntp                  : \~0.1.1
  'istanbul-middleware' : \~0.1.1
  jade                  : \~1.6.0
  levelup               : \~0.19.0 # cacheify
  LiveScript            : \~1.2.0
  marked                : \~0.3.1
  'marionette-client'   : \git://github.com/dizzib/marionette-js-client.git#newSandbox
  'marionette-js-logger': \~0.1.2
  memdown               : \~0.10.2 # cacheify
  mocha                 : \~1.15.1
  mongodb               : \~1.2.14
  nib                   : \~0.9.0
  request               : \~2.16.6
  shelljs               : \~0.2.6
  stylus                : \~0.31.0
  'uglify-js'           : \~2.4.12
  'variadic.js'         : \~0.0.1
  'wait.for'            : \~0.6.3
