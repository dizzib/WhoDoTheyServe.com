_ = require \underscore
H = require \../../helper
M = require \../../model

exports
  ..apply-layout = (nodes) ->
    layout = JSON.parse M.Hive.Graph.get \value
    _.each nodes, ->
      if pos = _.findWhere layout, id:it._id then
        it
          #..fixed = true
          ..x  = pos.x
          ..y  = pos.y
    nodes

  ..save-layout = (graph) ->
    layout = _.map graph.nodes!, ->
      id: it._id
      x : Math.round it.x
      y : Math.round it.y
    json = JSON.stringify layout
    M.Hive.Graph.save value:JSON.stringify layout,
      fail   : -> H.log \fail
      success: -> H.log \ok
