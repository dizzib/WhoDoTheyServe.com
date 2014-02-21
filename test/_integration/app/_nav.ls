B  = require \./_browser
ST = require \../state

module.exports =
  go-edge-or-node: (key) ->
    #  X:n is node e.g. a:0
    # XX:n is edge e.g. ab:0 = from node a to b
    # where :n is optional evidence key
    ent-key = if key.indexOf(':') > 0 then key.split ':' .0 else key
    is-node = ent-key.length is 1

    name = if is-node then ST.nodes[ent-key] else new RegExp "---#ent-key---"
    throw new Error "entity #ent-key must first be created" unless name?

    B.click (legend = if is-node then \Actors else \Connections), \a
    B.wait-for-visible (new RegExp legend), \legend
    B.click name, \a
    B.wait-for-visible name, if is-node then 'h2>.name' else 'h2>.how'
