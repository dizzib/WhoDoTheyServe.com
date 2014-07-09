Data    = require \./graph.json
Hive    = require \../../api/hive
M-Nodes = require \../../api/model/nodes

exports
  # store graph icon data in hive since it's not core
  ..set-icons = ->
    err, nodes <- M-Nodes.find!lean!exec
    return console.error err if err
    json = Hive.get \graph
    value = if json then JSON.parse json else {}
    delete value.glyphs # TODO: remove this line when migrated
    value.icons = []
    for node in nodes
      for d in Data.icons
        if node.name.match d.name then
          o = { id:node._id }
            ..glyph ?= d.glyph
            ..image ?= d.image
            ..size  ?= d.size
          value.icons.push o
    Hive.set \graph, JSON.stringify value
