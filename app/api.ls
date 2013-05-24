B = require \backbone

const API-URL = \http://wdts.eu01.aws.af.cm/api

exports
  ..init      = init-for-cross-domain
  # endpoints
  ..edges     = get-url \edges
  ..evidences = get-url \evidences
  ..nodes     = get-url \nodes
  ..notes     = get-url \notes
  ..sessions  = get-url \sessions
  ..sys       = get-url \sys
  ..users     = get-url \users

function get-url endpoint then
  loc = window.location
  is-prod  = /\.(com|net)$/.test loc.hostname or /prod/.test loc.search
  url-root = if is-prod then API-URL else \/api
  "#{url-root}/#{endpoint}"

# http://backbonetutorials.com/cross-domain-sessions/
function init-for-cross-domain then
  $.ajaxPrefilter (opts) ->
    opts.xhrFields = withCredentials:true
