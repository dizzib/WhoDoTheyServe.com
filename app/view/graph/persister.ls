_ = require \underscore
H = require \../../helper
M = require \../../model

exports
  ..apply-layout = (nodes) ->
    return nodes unless json = M.Hive.Graph.get \value
    layout = JSON.parse json
    _.each nodes, ->
      if pos = _.findWhere layout, id:it._id then
        it.x = pos.x
        it.y = pos.y
    nodes

  ..save-layout = (d3-force) ->
    layout = _.map d3-force.nodes!, ->
      id: it._id
      x : Math.round it.x
      y : Math.round it.y
    M.Hive.Graph.save value:JSON.stringify(layout),
      fail   : -> H.log \fail
      success: -> H.log \ok
