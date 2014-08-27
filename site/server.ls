global.log = console.log

Express   = require \express
Im        = require \istanbul-middleware if is-cover = process.env.COVERAGE is \true
_         = require \lodash
Passport  = require \passport
H         = require \./api/helper

const ONE-HOUR = 60m * 60s * 1000ms
const DIR-APP  = "#{__dirname}/app"

cookie-opts =
  secret: process.env.WDTS_COOKIE_SECRET or \secret
  cookie:
    maxAge: 4 * ONE-HOUR # https://github.com/senchalabs/connect/issues/670

# http://docs.aws.amazon.com/AmazonCloudFront/2010-11-01/DeveloperGuide/Expiration.html
static-opts =
  maxAge: ONE-HOUR

Im.hookLoader __dirname if is-cover
env = (express = Express!).settings.env

module.exports = express
  ..set \port, process.env.PORT || 80
  ..use '/coverage', Im.createHandler! if is-cover
  ..use Express.favicon \./app/asset/favicon.png, static-opts
  ..use Express.logger \dev if env in <[ development ]>
  ..use Express.compress! if env in <[ staging production ]>
  ..use Express.cookieParser!
  ..use Express.cookieSession cookie-opts
  ..use Express.bodyParser!
  ..use allow-cross-domain
  ..use Passport.initialize!
  ..use express.router
  ..use Express.static DIR-APP, static-opts
  ..use Im.createClientHandler DIR-APP, matcher:matcher if is-cover
  ..use log-error show-stack:env in <[ development staging production ]>
  ..use handle-error
  ..use Express.errorHandler! if env in <[ development ]>


# http://backbonetutorials.com/cross-domain-sessions/
function allow-cross-domain req, res, next
  res.set \Access-Control-Allow-Credentials, true
  res.set \Access-Control-Allow-Headers    , 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  res.set \Access-Control-Allow-Methods    , 'GET,POST,PUT,DELETE,OPTIONS'
  res.set \Access-Control-Allow-Origin     , req.headers.origin
  next!

function get-validation-msg err
  return _.reduce err.errors, iterator, ''
  function iterator memo, err then memo + "#{err.message}\n"

function handle-error err, req, res, next
  if err instanceof H.AuthenticateError
    return res.redirect "http://#{H.get-host-site!}/#/user/signin/error?error_description=#{err.message}"
  msg = switch
    | err instanceof H.ApiError    => err.message
    | err.name is \ValidationError => get-validation-msg err
    | _ =>
      if env in <[ development staging test ]> then err.stack
      else 'Internal server error, sorry! :('
  res.send 500, msg

function log-error opts
  (err, req, res, next) ->
    msg = if err.name is \ValidationError then get-validation-msg err else err.message
    # to avoid a flood of growls during a test run, we log rather than logerr
    log if opts.show-stack and err.stack then err.stack else msg
    next err

function matcher req
  /(app|loader)\.js/.test req.url
