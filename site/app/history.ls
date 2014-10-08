# For auto-populating new entities with previous entities e.g. a new edge
# might be auto-populated with the 2 last-edited nodes.

node-ids = [ void, void ]

module.exports =
  get-edge: ~> @edge

  get-node-id: -> node-ids[it]

  set-edge: (@edge) ~>

  set-node-id: ->
    return if it is node-ids.0
    if it is node-ids.1 then return node-ids.reverse!
    node-ids
      ..unshift it
      ..pop!
