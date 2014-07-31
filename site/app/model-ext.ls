_  = require \underscore
C  = require \./collection
Hi = require \./history
M  = require \./model
S  = require \./session

module.exports.init = ->
  # extend models with custom methods

  M.Edge .= extend do
    is-in-map: (node-ids) ->
      (_.contains node-ids, @get \a_node_id) and (_.contains node-ids, @get \b_node_id)
    toJSON-T: (opts) ->
      function get-period is-tip
        return '' if node-yyyy and not is-tip
        if yyyy then return "in #{yyyy}"
        period = "from #{year-from or '?'}"
        period + if year-to then " to #{year-to}" else ''
      ~function get-tip
        how = "#{if how = @get \how then ' - ' + how else ''}"
        "Evidence#{how} #{get-period true}"

      a-node    = C.Nodes.get @get \a_node_id # undefined if new
      b-node    = C.Nodes.get @get \b_node_id # undefined if new
      year-from = @get \year_from
      year-to   = @get \year_to
      node-yyyy = a-node?get-yyyy! or b-node?get-yyyy!
      year      = if year-from is year-to then year-from
      yyyy      = year?toString! or node-yyyy
      _.extend (@toJSON opts),
        a_node_name: a-node?get \name
        b_node_name: b-node?get \name
        a_is_eq    : \eq is @get \a_is
        a_is_lt    : \lt is @get \a_is
        period     : get-period!
        tip        : get-tip!
        yy         : yyyy?substring 2
        yyyy       : yyyy
        year       : parseInt yyyy

  M.Evidence .= extend do
    get-glyph: ->
      const GLYPHS =
        * name:\fa-file-pdf-o   unicode:\\uf1c1 regex:/\.pdf$/i
        * name:\fa-video-camera unicode:\\uf03d regex:/youtube\.com|vimeo\.com/i
      for g in GLYPHS then return g if g.regex.test @get \url
      name:\fa-file-text-o unicode:\\uf0f6
    toJSON-T: (opts) ->
      _.extend (@toJSON opts),
        glyph: @get-glyph!

  M.Map .= extend do
    get-is-editable: -> @isNew! or S.get-id! is (@get \meta .create_user_id)
    initialize: ->
      @on \sync, (map, res, opts) ->
        return unless opts.parse and ents = res.entities
        # merge newly read map entities into global entities
        C.Edges.set (_.map ents.edges, -> new M.Edge it), remove:false
        C.Evidences.set (_.map ents.evidences, -> new M.Evidence it), remove:false
        C.Nodes.set (_.map ents.nodes, -> new M.Node it), remove:false
        C.Notes.set (_.map ents.notes, -> new M.Note it), remove:false

  M.Node .= extend do
    get-yyyy: ->
      /[12]\d{3}$/.exec(@get \name)?0
    toJSON-T: (opts) ->
      function get-family-name node
        return unless name = node.get \name
        name.match(/^\w+,/)?0.replace ',', ''
      _.extend (@toJSON opts),
        family-name: get-family-name this
        tip        : 'Evidence'

  M.User .= extend do
    get-is-admin: ->
      \admin is @get \role

  # add factory methods

  M.Edge.create = ->
    m = create M.Edge, it
    unless it # auto-populate new edge with 2 last nodes
      m.set \a_node_id, Hi.get-node-id 0
      m.set \b_node_id, Hi.get-node-id 1
      if (edge = Hi.get-edge!) then m.set \how, edge.get \how
    m

  add-factory-method M.Evidence
  add-factory-method M.Map
  add-factory-method M.Node
  add-factory-method M.Note
  add-factory-method M.Session
  add-factory-method M.Signup
  add-factory-method M.Sys
  add-factory-method M.User

  # helpers

  function add-factory-method model then model.create = -> create model, it

  function create model, id
    (m = new model!).id = id
    m
