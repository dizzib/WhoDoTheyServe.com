Data    = require \./map.json
Hive    = require \../../api/hive
M-Nodes = require \../../api/model/nodes

module.exports = # store map icon data in hive since it's not core
  set-icons: ->
    err, nodes <- M-Nodes.find!lean!exec
    return console.error err if err
    json = Hive.get \map
    value = if json then JSON.parse json else {}
    value.icons = []
    for node in nodes
      for d in Data.icons when node.name.match d.name
        o = id:node._id
        o.glyph ?= d.glyph
        o.image ?= d.image
        o.size  ?= d.size
        value.icons.push o
    Hive.set \map, JSON.stringify value
