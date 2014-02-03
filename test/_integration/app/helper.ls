F  = require \./firedrive
ST = require \../state

module.exports =
  assert-ok: (is-ok = true) ->
    F.assert.displayed !is-ok, class:\alert-error

  go-entity: (key) ->
    #  X:n is node e.g. a:0
    # XX:n is edge e.g. ab:0 = from node a to b
    # where :n is optional evidence key
    ent-key = if key.indexOf(':') > 0 then key.split ':' .0 else key
    is-node = ent-key.length is 1

    name = if is-node then ST.nodes[ent-key]
    else new RegExp "---#{ent-key}---"

    throw new Error "entity #{ent-key} must first be created" unless name?

    F.click if is-node then \Actors else \Connections
    F.click name, \a
    F.wait-for name, if is-node then \h2>.name else \h2>.how
