# set global log fn
# note we can't just set window.log = console.log because we'll get
# 'illegal invocation' errors, since console.log expects 'this' to be console.
window.log = -> console.log ...&

# ensure untrapped errors are logged for marionette-js-logger test runner
window.onerror = (msg, url, line) ->
  log "#msg (#url line #line)"
  false # propogate

B  = require \backbone
Bb = require \./backbone
C  = require \./collection
Cs = require \./collections
S  = require \./session

require \./view-handler/event
require \./view-handler/ui

C.init do
  Evidence: require \./model/evidence
  Edge    : require \./model/edge
  Latest  : require \./model/latest
  Map     : require \./model/map
  Node    : require \./model/node
  Note    : require \./model/note
  User    : require \./model/user
  Session : require \./model/session
C.Sessions.fetch error:fail, success:boot

## helpers

function alert type, xhr
  info   = "Unable to load #type entities.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#info\n\n#prompt" then window.location.reload!

function boot
  Cs.fetch-core (-> Cs.fetch-all start-signed-in, fail-si), fail if S.is-signed-in!
  Cs.fetch-core start, fail unless S.is-signed-in!
  B.trigger \boot

function fail coll, xhr then alert \core xhr
function fail-si coll, xhr then alert \signin xhr

function load-lib-signin cb
  yepnope load:\lib-signin.js complete:cb

function start
  B.once \signin load-lib-signin
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot

function start-signed-in
  <- load-lib-signin
  B.trigger \signin
  start!
