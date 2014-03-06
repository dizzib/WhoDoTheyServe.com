_ = require \underscore
H = require \../../helper
M = require \../../model

module.exports =
  apply-layout: (nodes) ~>
    if json = M.Hive.Graph.get \value then
      @value = JSON.parse json
      _.each nodes, ~>
        if pos = _.findWhere @value.layout, id:it._id then
          it.x = pos.x
          it.y = pos.y
    nodes

  is-persisted: ->
    M.Hive.Graph.has \value

  save-layout: (d3-force) ~>
    return alert 'no @value' unless @value
    @value.layout = _.map d3-force.nodes!, ->
      id: it._id
      x : Math.round it.x
      y : Math.round it.y
    M.Hive.Graph.save value:JSON.stringify(@value),
      fail   : -> alert \fail
      success: -> alert \ok
