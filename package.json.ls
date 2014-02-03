version: \0.1.0
scripts:
# DANGER: each line must end in a space for livescript multiline to work!
  start: "
    NODE_ENV=development PORT=4000 
    WDTS_DB_CACHE_ENABLE=true 
    WDTS_DB_CACHE_SWEEP_PERIOD_MINS=10 
    WDTS_DB_URI=mongodb://localhost/wdts_dev 
    nodemon boot.js
  "
  test: "
    NODE_ENV=test PORT=4001 
    FIREFOX_HOST=scratch 
    WDTS_DB_URI=mongodb://localhost/wdts_test 
    WDTS_USER_SIGNIN_BAD_FREEZE_SECS=0 
    nodemon --delay 0 node_modules/mocha/bin/mocha --reporter spec --growl --bail --recursive 
  "
dependencies:
  bcrypt      : \0.7.5
  crypto      : \0.0.3
  express     : \3.1.1
  mongoose    : \3.5.5
  underscore  : \1.4.4
devDependencies:
  brfs                : \0.0.x
  browserify          : \3.24.x
  chai                : \1.8.x
  colors              : \0.6.x
  jade                : \0.27.x
  'marionette-client' : \1.1.x
  mocha               : \1.15.x
  mongodb             : \1.2.x
  request             : \2.16.x
  stylus              : \0.31.x
  'variadic.js'       : \0.0.x
  'wait.for'          : \0.6.x
