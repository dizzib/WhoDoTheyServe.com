node-ids = [ void, void ]

exports
  ..get-edge = ~> @edge

  ..get-node-id = ->
    node-ids[it]

  ..set-edge = (@edge) ~>

  ..set-node-id = ->
    return if it is node-ids.0
    if it is node-ids.1 then return node-ids.reverse!
    node-ids
      ..unshift it
      ..pop!
