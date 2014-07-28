# set global log fn
# note we can't just set window.log = console.log becuase we'll get
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
H   = require \./helper
M   = require \./model
Mx  = require \./model-ext
S   = require \./session
V   = require \./view
Val = require \./validator
Vh  = require \./view-handler
Vf  = require \./view/footer
Vsi = require \./view/user-signin

H.insert-css F.readFileSync __dirname + \/lib/form.css
H.insert-css F.readFileSync __dirname + \/lib-3p/bootstrap-combobox.css
H.insert-css F.readFileSync __dirname + \/lib-3p/multiple-select.css
H.insert-css-seo F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

B.Model.prototype.idAttribute = \_id # mongodb

Api.init!
Mx .init!
C  .init!

C.Sessions.fetch error:fail, success:init

# helpers

function alert type, xhr
  info   = "Unable to load #type entities.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#info\n\n#prompt" then window.location.reload!

function init
  fetch-entities-core (-> Vsi.fetch-entities start, fail-si) if S.is-signed-in!
  fetch-entities-core start unless S.is-signed-in!
  Val.init!
  Vh .init!
  Vf .init!
  M.Sys.fetch error:fail, success: -> V.version.render!

function fail-si coll, xhr then alert \signed-in, xhr
function fail    coll, xhr then alert \core, xhr

function fetch-entities-core cb
  $.when(C.Maps.fetch!, C.Users.fetch!, M.Hive.Map.fetch!).then cb, fail

function start
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot
