name   : \wdts
version: \0.1.0
private: true
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
    WDTS_DB_URI=mongodb://localhost/wdts_test 
    WDTS_USER_SIGNIN_BAD_FREEZE_SECS=0 
    nodemon node_modules/mocha/bin/mocha --reporter dot --growl --bail --recursive 
  "
dependencies:
  bcrypt      : \0.7.5
  crypto      : \0.0.3
  express     : \3.1.0
  mongoose    : \3.5.5
  underscore  : \1.4.4
  zombie      : \2.0.0-alpha15
devDependencies:
  brfs        : \0.0.x
  browserify  : \2.12.x
  chai        : \1.5.x
  'insert-css': \0.0.0
  jade        : \0.27.x
  mocha       : \1.7.x
  mongodb     : \1.2.x
  request     : \2.16.x
  stylus      : \0.31.x
engines:
  node: \0.10.4
  npm : \1.2.18
