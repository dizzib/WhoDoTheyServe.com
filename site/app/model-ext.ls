_  = require \underscore
C  = require \./collection
Hs = require \./history
M  = require \./model

exports.init = ->
  M.Edge .= extend do
    toJSON-T: (opts) ->
      a-node    = C.Nodes.get @get \a_node_id # undefined if new
      b-node    = C.Nodes.get @get \b_node_id # undefined if new
      year-from = @get \year_from
      year-to   = @get \year_to
      node-yyyy = a-node?get-yyyy! or b-node?get-yyyy!
      year      = if year-from is year-to then year-from
      yyyy      = year?toString! or node-yyyy
      return _.extend (@toJSON opts),
        a_node_name: a-node?get \name
        b_node_name: b-node?get \name
        a_is_eq    : \eq is @get \a_is
        a_is_lt    : \lt is @get \a_is
        period     : get-period!
        tip        : get-tip!
        yy         : yyyy?substring 2
        yyyy       : yyyy
        year       : parseInt yyyy
      function get-period is-tip then
        return '' if node-yyyy and not is-tip
        if yyyy then return "in #{yyyy}"
        period = "from #{year-from or '?'}"
        period + if year-to then " to #{year-to}" else ''
      ~function get-tip then
        how = "#{if how = @get \how then ' - ' + how else ''}"
        "Evidence#{how} #{get-period true}"
  M.Evidence .= extend do
    toJSON-T: (opts) ->
      _.extend (@toJSON opts),
        glyph: @get-glyph!
    get-glyph: ->
      const GLYPHS =
        * name:\fa-file-pdf-o   unicode:\\uf1c1 regex:/\.pdf$/i
        * name:\fa-video-camera unicode:\\uf03d regex:/youtube\.com|vimeo\.com/i
      for g in GLYPHS then return g if g.regex.test @get \url
      name:\fa-file-text-o unicode:\\uf0f6
  M.Node .= extend do
    toJSON-T: (opts) ->
      return _.extend (@toJSON opts),
        family-name: get-family-name this
        tip        : 'Evidence'
      function get-family-name node then
        return unless name = node.get \name
        name.match(/^\w+,/)?0.replace ',', ''
    get-yyyy: ->
      /[12]\d{3}$/.exec(@get \name)?0

  M.Edge.create = ->
    m = create M.Edge, it
    unless it then # auto-populate new edge with 2 last nodes
      m.set \a_node_id, Hs.get-node-id 0
      m.set \b_node_id, Hs.get-node-id 1
      if (edge = Hs.get-edge!) then m.set \how, edge.get \how
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
