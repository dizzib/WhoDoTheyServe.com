B          = require \backbone
F          = require \fs # inlined by brfs
Insert-css = require \./lib-3p/insert-css
C          = require \./collection
H          = require \./helper
M-Ext      = require \./model-ext
S          = require \./session
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

C.Sessions.on \sync, -> V.navigator.render $ \.navbar

$.fn.set-access = ->
  show-or-hide \.signed-in      , S.is-signed-in!
  show-or-hide \.signed-in-admin, S.is-signed-in-admin!
  show-or-hide \.signed-out     , S.is-signed-out!
  @find '.signed-in-admin input' .prop \disabled, not S.is-signed-in-admin!
  return this

  ~function show-or-hide sel, show then
    @find sel .addClass if show then \show else \hide

fetch-edges!

function fetch-edges    then C.Edges.fetch    error:H.on-err, success:fetch-nodes
function fetch-nodes    then C.Nodes.fetch    error:H.on-err, success:fetch-sessions
function fetch-sessions then C.Sessions.fetch error:H.on-err, success:fetch-users
function fetch-users    then C.Users.fetch    error:H.on-err, success:start
function start          then B.history.start!
