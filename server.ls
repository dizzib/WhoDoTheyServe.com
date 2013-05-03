Express = require \express
_       = require \underscore
H       = require \./api/helper

cookie-opts =
  secret: process.env.WDTS_COOKIE_SECRET or \secret
  cookie:
    maxAge: 60m * 60s * 1000ms

module.exports = server = Express!
  ..set \port, process.env.PORT || 80
  ..use Express.favicon! if env = server.settings.env
  ..use Express.logger \dev if env in <[ development test staging production ]>
  ..use Express.compress! if env in <[ staging production ]>
  ..use Express.cookieParser!
  ..use Express.cookieSession cookie-opts
  ..use Express.bodyParser!
  ..use server.router
  ..use Express.static "#{__dirname}/app"
  ..use log-error show-stack:yes if env in <[ development ]>
  ..use log-error show-stack:no  if env in <[ test staging production ]>
  ..use handle-error
  ..use Express.errorHandler! if env in <[ development ]>

function handle-error err, req, res, next then
  msg = switch
    | err instanceof H.ApiError    => err.message
    | err.name is \ValidationError => get-validation-msg err
    | otherwise                    => 'Internal server error, sorry! :('
  res.send 500, msg

function log-error opts then
  (err, req, res, next) ->
    msg = if err.name is \ValidationError then get-validation-msg err else err.message
    console.log if opts.show-stack and err.stack then err.stack else msg
    next err

function get-validation-msg err
  return _.reduce err.errors, iterator, ''
  function iterator memo, err then memo + "#{err.message}\n"
