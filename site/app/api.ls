# api calls bypass CF by calling the native provider domain not whodotheyserve.com
const PROD-URL = \http://wdts-dizzib0.rhcloud.com/api

module.exports =
  post-coverage: -> # https://github.com/gotwarlost/istanbul-middleware
    new XMLHttpRequest!
      ..open \POST, \/coverage/client
      ..setRequestHeader 'Content-Type', 'application/json; charset=UTF-8'
      ..send JSON.stringify window.__coverage__

  ## endpoints
  edges    : get-url \edges
  evidences: get-url \evidences
  hive     : get-url \hive
  maps     : get-url \maps
  nodes    : get-url \nodes
  notes    : get-url \notes
  sessions : get-url \sessions
  sys      : get-url \sys
  users    : get-url \users

if is-prod! # http://backbonetutorials.com/cross-domain-sessions/
  $.ajaxPrefilter (opts) -> opts.xhrFields = withCredentials:true

## helpers

function get-url endpoint
  "#{if is-prod! then PROD-URL else \/api}/#{endpoint}"

function is-prod
  loc = window.location
  /whodotheyserve\.com$/.test loc.hostname or /prod/.test loc.search
