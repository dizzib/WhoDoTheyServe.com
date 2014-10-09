# set global log fn
# note we can't just set window.log = console.log because we'll get
# 'illegal invocation' errors, since console.log expects 'this' to be console.
window.log = -> console.log ...&

# ensure untrapped errors are logged for marionette-js-logger test runner
window.onerror = (msg, url, line) ->
  log "#msg (#url line #line)"
  false # propogate

B   = require \backbone
F   = require \fs # inlined by brfs
Api = require \./api
C   = require \./collection
E   = require \./entities
H   = require \./helper
S   = require \./session
Si  = require \./signin
V   = require \./view
Vh  = require \./view-handler

M-Edge = require \./model/edge
M-Evi  = require \./model/evidence
M-Map  = require \./model/map
M-Node = require \./model/node
M-Note = require \./model/note
M-User = require \./model/user
M-Sess = require \./model/session
M-Sys  = require \./model/sys

H.insert-css F.readFileSync __dirname + \/lib/form.css
H.insert-css F.readFileSync __dirname + \/lib-3p/bootstrap-combobox.css
H.insert-css-seo F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

init-backbone!
Api.init!
C.init do
  Evidence: M-Evi
  Edge    : M-Edge
  Map     : M-Map
  Node    : M-Node
  Note    : M-Note
  User    : M-User
  Session : M-Sess
C.Sessions.fetch error:fail, success:init

# helpers

function alert type, xhr
  info   = "Unable to load #type entities.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#info\n\n#prompt" then window.location.reload!

function fail coll, xhr
  alert \core, xhr

function fail-si coll, xhr
  alert \signed-in, xhr

function init
  E.fetch-core (-> E.fetch-all start-signed-in, fail-si), fail if S.is-signed-in!
  E.fetch-core start, fail unless S.is-signed-in!
  Vh.init!
  V.footer.render!
  (sys = M-Sys.instance).fetch error:fail, success: -> V.version.render sys

function init-backbone
  B.Model.prototype.idAttribute = \_id # mongodb
  _invalid = B.Validation.callbacks.invalid
  B.Validation
    ..configure labelFormatter:\label
    ..callbacks.invalid = ->
      _invalid ...
      H.show-error "One or more fields have errors. Please correct them before retrying."

function start
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot

function start-signed-in
  Si.after-signin!
  start!
