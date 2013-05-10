B          = require \backbone
F          = require \fs # inlined by brfs
Insert-css = require \./lib-3p/insert-css
C          = require \./collection
H          = require \./helper
M-Ext      = require \./model-ext
V          = require \./view
V-Event    = require \./view-event
Router     = require \./router

Insert-css F.readFileSync __dirname + \/lib/form.css
Insert-css F.readFileSync __dirname + \/index.css
Insert-css F.readFileSync __dirname + \/view/edge.css
Insert-css F.readFileSync __dirname + \/view/footer.css

B.Model.prototype.idAttribute = \_id  # mongodb
M-Ext.init!
C.init!
V-Event.init Router
wire-events!
fetch-edges!
keep-alive! # prevent server sleeping after period of inactivity
C.Evidences.fetch error:on-err
C.Notes    .fetch error:on-err
C.Sessions .fetch error:on-err
C.Users    .fetch error:on-err

function fetch-edges then C.Edges.fetch error:H.on-err, success:fetch-nodes
function fetch-nodes then C.Nodes.fetch error:H.on-err, success:start
function start       then B.history.start!

function keep-alive then
  const PERIOD = 10mins * 60s * 1000ms
  $.ajax \/api/keep-alive complete: -> setTimeout keep-alive, PERIOD

function on-err coll, xhr then
  info   = "The app failed to start.\n\n#{xhr.responseText}"
  prompt = "Press 'OK' to reload or 'cancel' to close this dialog"
  if confirm "#{info}\n\n#{prompt}" then window.location.reload!

function wire-events then
  C.Sessions.on \sync, -> V.navigator.render $ \.navbar
