_ = require \underscore
H = require \../../helper
M = require \../../model

exports
  ..apply-layout = (nodes) ->
    if json = M.Hive.Graph.get \value then
      value = JSON.parse json
      _.each nodes, ->
        if pos = _.findWhere value.layout, id:it._id then
          it.x = pos.x
          it.y = pos.y
    nodes

  ..is-persisted = ->
    M.Hive.Graph.has \value

  ..save-layout = (d3-force) ->
    layout = _.map d3-force.nodes!, ->
      id: it._id
      x : Math.round it.x
      y : Math.round it.y
    value = JSON.stringify layout:layout
    M.Hive.Graph.save value:value,
      fail   : -> H.log \fail
      success: -> H.log \ok
