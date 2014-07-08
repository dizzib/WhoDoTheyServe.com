_ = require \lodash
C = require \../collection
F = require \../fireprox
H = require \../helper
M = require \../model

const COMMAND-GET-URL = \content.location.href

var ev-dead-ids

module.exports =
  create: (entity-id, cb) ->
    <- F.send-request COMMAND-GET-URL
    return cb! unless it
    ev = new M.Evidence entity_id:entity-id, url:it
    C.Evidences.create ev, { +merge, +wait, error:H.on-err, success: -> cb ok:true }

  init: ->
    return if $ \#url .attr \value
    <- F.send-request COMMAND-GET-URL
    $ \#url .attr \value, it

  is-dead: (id) ->
    unless ev-dead-ids # lazy init
      json = M.Hive.Evidences.get \value
      ev-dead-ids := if json then JSON.parse(json).'dead-ids' else []
    _.contains ev-dead-ids, id
