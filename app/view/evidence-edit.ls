# fireprox helps automate input of evidence
C = require \../collection
H = require \../helper
M = require \../model

const STORE-KEY = \fireprox-url

exports
  ..auto-add = (entity-id, cb) ->
    <- fetch-evidence-url
    return cb! unless it
    ev = new M.Evidence entity_id:entity-id, url:it
    C.Evidences.create ev, { +merge, +wait, error:H.on-err, success: -> cb ok:true }

  ..prepare-edit = ->
    return if $ \#url .attr \value
    <- fetch-evidence-url
    $ \#url .attr \value, it

  ..set-fireprox-url = ->
    return H.log 'localStorage not supported' unless localStorage
    url = prompt 'Fireprox url', localStorage.getItem(STORE-KEY)
    return if url is null
    if url?length then
      localStorage.setItem STORE-KEY, url
    else
      localStorage.removeItem STORE-KEY

function fetch-evidence-url cb then
  return cb! unless url = localStorage?getItem STORE-KEY
  $.ajax "#{url}/exec/content.location.href",
    error: ->
      H.log ...
      cb!
    success: -> cb it.replace /"/g, ''
