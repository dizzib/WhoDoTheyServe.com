_ = require \underscore
C = require \./collection
H = require \./helper
M = require \./model

exports.init = ->
  M.Edge .= extend do
    toJSON-T: (opts) ->
      j = @toJSON opts
      _.extend j, a_node_name:(C.Nodes.get @get \a_node_id)?get \name
      _.extend j, b_node_name:(C.Nodes.get @get \b_node_id)?get \name
      _.extend j, a_is_eq: \eq is @get \a_is
      _.extend j, a_is_lt: \lt is @get \a_is
      _.extend j, tip    : get-tip    this
      _.extend j, period : get-period this
      return j
      function get-period edge then
        yf = edge.get \year_from
        yt = edge.get \year_to
        if yf and yf is yt then return "in #{yt}"
        f = "from #{yf or '?'} "
        t = if yt then "to #{yt}" else ''
        f + t
      function get-tip edge then
        how = "#{if (how = edge.get \how) then ' - ' + how else ''}"
        period = get-period edge
        "Evidence#{how}, #{period}"
    in_range: (y_from, y_to) ->
      yf = @get(\year_from) or 0
      yt = @get(\year_to)   or 9999
      not (yf > y_to or yt < y_from)
  M.Evidence .= extend do
    toJSON-T: (opts) ->
      j = @toJSON opts
      _.extend j, is-video: /youtube\.com/.test @get \url
      return j
  M.Node .= extend do
    toJSON-T: (opts) ->
      j = @toJSON opts
      _.extend j, tip: 'Evidence'
      _.extend j, family-name: get-family-name this
      return j
      function get-family-name node then
        matches = node.get \name .match /^\w+,/
        return matches?0.replace ',', ''

  add-factory-method M.Evidence
  add-factory-method M.Edge
  add-factory-method M.Node
  add-factory-method M.Note
  add-factory-method M.Session
  add-factory-method M.Signup
  add-factory-method M.Sys
  add-factory-method M.User

  function add-factory-method Model then
    Model.create = ->
      (m = new Model!).id = it
      return m
