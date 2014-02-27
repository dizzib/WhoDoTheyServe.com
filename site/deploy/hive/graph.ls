Data    = require \./graph.json
H       = require \../../api/helper
Hive    = require \../../api/hive
M-Nodes = require \../../api/model/nodes

exports
  # store graph image-url data in hive since it's not core data
  ..set-images = ->
    err, nodes <- M-Nodes.find!lean!exec
    return H.log err if err
    json = Hive.get \graph
    value = if json then JSON.parse json else {}
    value.images = []
    for node in nodes
      for d in Data.images
        if node.name.match d.name then
          value.images.push id:node._id, url:d.url, size:d.size
    Hive.set \graph, JSON.stringify value
