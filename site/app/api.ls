B = require \backbone

const PROD-URL = \http://wdts10.eu01.aws.af.cm/api

module.exports =
  init     : -> init-for-cross-domain! if check-is-prod!
  # endpoints
  edges    : get-url \edges
  evidences: get-url \evidences
  hive     : get-url \hive
  maps     : get-url \maps
  nodes    : get-url \nodes
  notes    : get-url \notes
  sessions : get-url \sessions
  sys      : get-url \sys
  users    : get-url \users

function check-is-prod
  loc = window.location
  /whodotheyserve\.com$/.test loc.hostname or /prod/.test loc.search

function get-url endpoint
  "#{if check-is-prod! then PROD-URL else \/api}/#{endpoint}"

# http://backbonetutorials.com/cross-domain-sessions/
function init-for-cross-domain
  $.ajaxPrefilter (opts) ->
    opts.xhrFields = withCredentials:true
