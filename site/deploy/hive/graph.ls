Data    = require \./graph.json
Hive    = require \../../api/hive
M-Nodes = require \../../api/model/nodes

exports
  # store graph image-url data in hive since it's not core data
  ..set-images = ->
    err, nodes <- M-Nodes.find!lean!exec
    return console.error err if err
    json = Hive.get \graph
    value = if json then JSON.parse json else {}
    delete value.images # migrate away from images TODO: remove this line when done
    value.glyphs = []
    for node in nodes
      for d in Data.glyphs
        if node.name.match d.name then
          o = { id:node._id }
            ..ucid ?= d.ucid
            ..img  ?= d.img
            ..size ?= d.size
          value.glyphs.push o
    Hive.set \graph, JSON.stringify value
