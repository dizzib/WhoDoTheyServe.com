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
V   = require \./view
Val = require \./validator
Vh  = require \./view-handler
Vf  = require \./view/footer
Vme = require \./view/graph/edit

H.insert-css F.readFileSync __dirname + \/lib/form.css
H.insert-css F.readFileSync __dirname + \/lib-3p/bootstrap-combobox.css
H.insert-css F.readFileSync __dirname + \/lib-3p/multiple-select.css
H.insert-css-seo F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

B.Model.prototype.idAttribute = \_id # mongodb

Api.init!
Mx .init!
C  .init!
Val.init!
Vh .init!
Vf .init!

$.when(
  C.Evidences     .fetch!
  C.Edges         .fetch!
  C.Maps          .fetch!
  C.Nodes         .fetch!
  C.Sessions      .fetch!
  C.Users         .fetch!
  M.Hive.Graph    .fetch!
  M.Hive.Evidences.fetch!
).then start, fail

C.Notes.fetch error:fail
M.Sys  .fetch error:fail, success: -> V.version.render!

Vme.init!

function fail coll, xhr
  info   = "The app failed to start.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#{info}\n\n#{prompt}" then window.location.reload!

function start
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot
