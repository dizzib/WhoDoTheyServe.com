_  = require \underscore
C  = require \./collection
E  = require \./entities
Hi = require \./history
M  = require \./model
S  = require \./session
W  = require \../lib/when

# extend models with custom methods

const VID-VIMEO   = service:\vimeo   rx:/vimeo\.com/i
const VID-YOUTUBE = service:\youtube rx:/youtube\.com|youtu\.be/i
M.Evidence .= extend do
  get-glyph: ->
    const GLYPHS =
      * name:\fa-file-pdf-o   unicode:\\uf1c1 rxs:[ /\.pdf$/i ]
      * name:\fa-video-camera unicode:\\uf03d rxs:[ VID-VIMEO.rx, VID-YOUTUBE.rx ]
    for g in GLYPHS then return g if _.find g.rxs, ~> it.test @get \url
    name:\fa-file-text-o unicode:\\uf0f6
  toJSON-T: (opts) ->
    _.extend (@toJSON opts),
      glyph: @get-glyph!
      video: _.find [ VID-VIMEO, VID-YOUTUBE ], ~> it.rx.test @get \url

M.Map .= extend do
  get-is-editable : -> @isNew! or S.get-id! is (@get \meta .create_user_id)
  has-been-fetched: -> @has \entities
  parse: ->
    return it unless es = it.entities
    it.entities = ents = # convert json to model instances for view/map
      edges    : _.map es.edges    , -> new M.Edge it
      evidences: _.map es.evidences, -> new M.Evidence it
      nodes    : _.map es.nodes    , -> new M.Node it
      notes    : _.map es.notes    , -> new M.Note it
    # add entities to global collections
    C.Nodes.set ents.nodes, remove:false # add nodes first so edge comparator can read node names
    C.Edges.set ents.edges, remove:false
    C.Evidences.set ents.evidences, remove:false
    C.Notes.set ents.notes, remove:false
    it

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
  get-is-admin: -> \admin is @get \role

add-factory-method M.Evidence
add-factory-method M.Map
add-factory-method M.Node
add-factory-method M.Note
add-factory-method M.Session
add-factory-method M.User

# helpers

function add-factory-method model then model.create = ->
  create model, it

function create model, id
  (m = new model!)
  # id might be null since backbone 1.1.2 router. For some reason, setting _id = null
  # causes mongo to create a document with _id as an ObjectId.
  m.set \_id, id if id?
  m
