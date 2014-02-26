# Set global log fn.
# Note we can't just set window.log = console.log becuase we'll get
# 'illegal invocation' errors, since console.log expects 'this' to be console.
window.log = -> console.log ...&

B      = require \backbone
F      = require \fs # inlined by brfs
Api    = require \./api
C      = require \./collection
H      = require \./helper
M      = require \./model
M-Ext  = require \./model-ext
P      = require \./view/graph/persister
VAL    = require \./validator
V      = require \./view
V-Hdlr = require \./view-handler
V-Foot = require \./view/footer
Router = require \./router

H.insert-css F.readFileSync __dirname + \/lib/form.css
H.insert-css-seo F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

B.Model.prototype.idAttribute = \_id  # mongodb

Api   .init!
M-Ext .init!
C     .init!
VAL   .init!
V-Hdlr.init Router
V-Foot.init!

$.when(
  C.Evidences .fetch!
  C.Edges     .fetch!
  C.Nodes     .fetch!
  C.Sessions  .fetch!
  C.Users     .fetch!
  M.Hive.Graph.fetch!
).then start, fail

C.Notes.fetch error:fail
M.Sys  .fetch error:fail, success: -> V.version.render!

function fail coll, xhr then
  info   = "The app failed to start.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#{info}\n\n#{prompt}" then window.location.reload!

function start then
  V.graph.init!
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot
