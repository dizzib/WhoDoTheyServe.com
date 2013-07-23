_  = require \underscore
C  = require \./collection
H  = require \./helper
HS = require \./history
M  = require \./model

exports.init = ->
  M.Edge .= extend do
    in_range: (y_from, y_to) ->
      yf = @get(\year_from) or 0
      yt = @get(\year_to)   or 9999
      not (yf > y_to or yt < y_from)
    toJSON-T: (opts) ->
      a-node    = C.Nodes.get @get \a_node_id # undefined if new
      b-node    = C.Nodes.get @get \b_node_id # undefined if new
      year-from = @get \year_from
      year-to   = @get \year_to
      node-yyyy = a-node?get-yyyy! or b-node?get-yyyy!
      year      = if year-from is year-to then year-from
      yyyy      = year?toString! or node-yyyy
      j         = @toJSON opts
      _.extend j, a_node_name: a-node?get \name
      _.extend j, b_node_name: b-node?get \name
      _.extend j, a_is_eq: \eq is @get \a_is
      _.extend j, a_is_lt: \lt is @get \a_is
      _.extend j, period : get-period!
      _.extend j, tip    : get-tip!
      _.extend j, yy     : yyyy?substring 2
      _.extend j, yyyy   : yyyy
      _.extend j, year   : parseInt yyyy
      return j
      function get-period is-tip then
        return '' if node-yyyy and not is-tip
        if yyyy then return "in #{yyyy}"
        period = "from #{year-from or '?'} "
        period + if year-to then "to #{year-to}" else ''
      ~function get-tip then
        how = "#{if how = @get \how then ' - ' + how else ''}"
        "Evidence#{how} #{get-period true}"
  M.Evidence .= extend do
    toJSON-T: (opts) ->
      j = @toJSON opts
      _.extend j, is-video: /youtube\.com/.test @get \url
      return j
  M.Node .= extend do
    toJSON-T: (opts) ->
      j = @toJSON opts
      _.extend j, family-name: get-family-name this
      _.extend j, tip : 'Evidence'
      return j
      function get-family-name node then
        return unless name = node.get \name
        name.match(/^\w+,/)?0.replace ',', ''
    get-yyyy: ->
      /[12]\d{3}/.exec(@get \name)?0

  M.Edge.create = ->
    m = create M.Edge, it
    unless it then # auto-populate new edge with 2 last nodes
      m.set \a_node_id, HS.get-node-id 0
      m.set \b_node_id, HS.get-node-id 1
      if (edge = HS.get-edge!) then m.set \how, edge.get \how
    return m

  add-factory-method M.Evidence
  add-factory-method M.Node
  add-factory-method M.Note
  add-factory-method M.Session
  add-factory-method M.Signup
  add-factory-method M.Sys
  add-factory-method M.User

  function add-factory-method Model then
    Model.create = -> create Model, it

  function create Model, id then
    (m = new Model!).id = id
    return m
