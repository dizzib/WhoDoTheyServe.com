F  = require \fs # inlined by brfs
_  = require \underscore
C  = require \../collection
F  = require \../fireprox
H  = require \../helper
Me = require \../model/evidence
Hv = require \../model/hive .instance

H.insert-css F.readFileSync __dirname + \/evidence.css

const COMMAND-GET-URL = \content.location.href

var ev-dead-ids

module.exports =
  create: (entity-id, cb) ->
    url <- F.send-request COMMAND-GET-URL
    return cb! unless url
    ev = Me.create entity_id:entity-id, url:url
    C.Evidences.create ev, { +merge, +wait, error:H.on-err, success:-> cb ok:true }

  init: ->
    return if $ \#url .attr \value
    <- F.send-request COMMAND-GET-URL
    $ \#url .attr \value, it

  is-dead: (id) ->
    ev-dead-ids := Hv.Evidences.get-prop \dead-ids or [] unless ev-dead-ids # lazy init
    _.contains ev-dead-ids, id
