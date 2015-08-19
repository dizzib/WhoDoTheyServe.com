name   : \wdts
version: \0.5.0
private: true
engines:
  node: '>=0.10.x'
  npm : '>=1.0.x'
scripts:
  start: 'node boot.js'
  task : './task/bootstrap && node ./_build/task/repl'
  test : './task/bootstrap && node ./_build/task/npm/test'
dependencies:
  bcrypt                  : \0.7.5
  'body-parser'           : \1.12.3
  compression             : \1.4.3
  'cookie-parser'         : \1.3.4
  'cookie-session'        : \1.1.0
  crypto                  : \0.0.3
  'custom-error-generator': \7.0.0
  errorhandler            : \1.3.5
  express                 : \4.12.3
  'http-status'           : \0.1.8
  lodash                  : \3.5.0
  mongoose                : \4.0.3
  morgan                  : \1.5.2
  passport                : \0.2.0
  'passport-facebook'     : \1.0.3
  'passport-github'       : \0.1.5
  'passport-google-oauth' : \0.1.5
  'serve-favicon'         : \2.2.0
  shortid                 : \2.0.0
devDependencies:
  brfs                  : \~0.0.9
  browserify            : \~3.24.13
  cacheify              : \~0.4.0
  chai                  : \~2.3.0
  chalk                 : \~0.4.0
  cheerio               : \~0.14.0
  chokidar              : \~1.0.1
  cron                  : \~1.0.3
  exposify              : \~0.1.4
  growly                : \~1.2.0
  'istanbul-middleware' : \~0.2.0
  jade                  : \~1.9.2
  levelup               : \~0.19.0 # cacheify
  livescript            : \~1.4.0
  marked                : \~0.3.1
  'marionette-client'   : \git://github.com/dizzib/marionette-js-client.git#newSandbox
  'marionette-js-logger': \0.1.2
  memdown               : \~0.10.2 # cacheify
  mocha                 : \~1.15.1
  mongodb               : \~1.2.14
  nib                   : \~1.1.0
  request               : \~2.16.6
  shelljs               : \~0.2.6
  stylus                : \~0.51.1
  'uglify-js'           : \~2.4.12
  'variadic.js'         : \~0.0.1
  'wait.for'            : \~0.6.3
