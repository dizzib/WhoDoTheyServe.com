BodyParser  = require \body-parser
Compress    = require \compression
CookiePars  = require \cookie-parser
CookieSess  = require \cookie-session
ErrHandler  = require \errorhandler
Express     = require \express
Favicon     = require \serve-favicon
HttpCode    = require \http-status
Im          = require \istanbul-middleware if process.env.COVERAGE is \true
_           = require \lodash
Logger      = require \morgan
Passport    = require \passport
Err         = require \./api/error
H           = require \./api/helper
OAuthMock   = require \./api/authenticate/openauth-mock if process.env.NODE_ENV is \test
OAuthRouter = require \./api/authenticate/router
Router      = require \./api/router

const ONE-HOUR = 60m * 60s * 1000ms
const DIR-APP  = "#{__dirname}/app"

cookie-opts =
  secret: process.env.WDTS_COOKIE_SECRET or \secret
  cookie:
    maxAge: 4 * ONE-HOUR # https://github.com/senchalabs/connect/issues/670

# http://docs.aws.amazon.com/AmazonCloudFront/2010-11-01/DeveloperGuide/Expiration.html
static-opts = maxAge:ONE-HOUR

env = (express = Express!).settings.env

module.exports = express
  ..use '/coverage', Im.createHandler! if Im
  ..use Favicon \./app/asset/favicon.png, static-opts
  ..use Logger \dev if env in <[ development ]>
  ..use Compress! if env in <[ staging production ]>
  ..use CookiePars!
  ..use CookieSess cookie-opts
  ..use BodyParser.json limit:\999kb
  ..use allow-cross-domain
  ..use Passport.initialize!

  # routes
  ..use '/api', Router
  #..use '/api/auth', OAuthRouter.create \facebook
  #..use '/api/auth', OAuthRouter.create \github
  #..use '/api/auth', OAuthRouter.create \google
  ..use '/api/auth', OAuthMock.create-router! if process.env.NODE_ENV is \test

  ..use Express.static DIR-APP, static-opts
  ..use Im.createClientHandler DIR-APP, matcher:matcher if Im
  ..use log-error show-stack:env in <[ development staging production ]>
  ..use handle-error
  ..use ErrHandler! if env in <[ development ]>

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
  if err instanceof Err.AuthenticateRequired
    return res.status HttpCode.UNAUTHORIZED .send err.message
  if err instanceof Err.Authenticate
    return res.redirect "http://#{H.get-host-site!}/#/user/signin/error?error_description=#{err.message}"
  msg = switch
    | err instanceof Err.Api       => err.message
    | err.name is \ValidationError => get-validation-msg err
    | _ => if env in <[ development test ]> then err.stack else 'Internal server error, sorry! :('
  res.status HttpCode.INTERNAL_SERVER_ERROR .send msg

function log-error opts
  (err, req, res, next) ->
    msg = if err.name is \ValidationError then get-validation-msg err else err.message
    # to avoid a flood of growls during a test run, we log rather than logerr
    log if opts.show-stack and err.stack then err.stack else msg
    next err

function matcher req then /(app|loader)\.js/.test req.url
