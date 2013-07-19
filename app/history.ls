_ = require \underscore

node-ids = [ void, void ]

exports
  ..get-edge = ~> @edge

  ..get-node-id = ->
    node-ids[it]

  ..set-edge = (@edge) ~>

  ..set-node-id = ->
    return if _.contains node-ids, it
    node-ids
      ..push it
      ..shift!
