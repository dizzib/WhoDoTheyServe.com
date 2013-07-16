B       = require \backbone
F       = require \fs # inlined by brfs
Ins-css = require \./lib-3p/insert-css
Api     = require \./api
C       = require \./collection
H       = require \./helper
M       = require \./model
M-Ext   = require \./model-ext
P       = require \./view/graph/persister
V       = require \./view
V-Event = require \./view-event
V-Foot  = require \./view/footer
Router  = require \./router

Ins-css F.readFileSync __dirname + \/lib/form.css
Ins-css F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

B.Model.prototype.idAttribute = \_id  # mongodb

Api    .init!
M-Ext  .init!
C      .init!
V-Event.init Router
V-Foot .init!

B.history.start!
$ \.hide-during-boot .removeClass \hide-during-boot

$.when(
  C.Evidences .fetch!
  C.Edges     .fetch!
  C.Nodes     .fetch!
  C.Sessions  .fetch!
  M.Hive.Graph.fetch!
).then (-> V.graph.init!), fail

C.Notes.fetch error:fail
C.Users.fetch error:fail
M.Sys  .fetch error:fail, success: -> V.version.render!

function fail coll, xhr then
  info   = "The app failed to start.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#{info}\n\n#{prompt}" then window.location.reload!
