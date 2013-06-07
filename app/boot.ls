B       = require \backbone
F       = require \fs # inlined by brfs
Ins-css = require \./lib-3p/insert-css
Api     = require \./api
C       = require \./collection
H       = require \./helper
M       = require \./model
M-Ext   = require \./model-ext
V       = require \./view
V-Event = require \./view-event
Router  = require \./router

Ins-css F.readFileSync __dirname + \/lib/form.css
Ins-css F.readFileSync __dirname + \/lib-3p-ext/bootstrap.css

B.Model.prototype.idAttribute = \_id  # mongodb

Api    .init!
M-Ext  .init!
C      .init!
V-Event.init Router

wire-events!

$.when(
  C.Edges    .fetch!
  C.Evidences.fetch!
  C.Nodes    .fetch!
  C.Notes    .fetch!
  C.Sessions .fetch!
  C.Users    .fetch!
  M.Sys      .fetch!
).then start, fail

function fail coll, xhr then
  info   = "The app failed to start.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#{info}\n\n#{prompt}" then window.location.reload!

function start then
  V.footer.render!
  V.version.render!
  V.graph.init!
  B.history.start!
  $ \.hide-during-boot .removeClass \hide-during-boot

function wire-events then
  C.Sessions.on \sync, -> V.navigator.render $ \.navbar
