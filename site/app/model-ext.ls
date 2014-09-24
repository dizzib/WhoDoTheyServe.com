_  = require \underscore
C  = require \./collection
E  = require \./entities
Hi = require \./history
M  = require \./model
S  = require \./session
W  = require \../lib/when

# extend models with custom methods

M.Edge .= extend do
  is-in-map: (node-ids) ->
    (_.contains node-ids, @get \a_node_id) and (_.contains node-ids, @get \b_node_id)
  toJSON-T: (opts) ->
    ~function get-tip
      "Evidence#{if how = @get \how then " - #how" else ''} #{get-when-text true}"

    function get-when-text is-tip
      return '' if yyyy and not is-tip
      return "in #yyyy" if yyyy
      s = "from #{when-obj.raw.from or '?'}"
      s + if (when-to = when-obj.raw.to) then " to #when-to" else ''

    a-node   = C.Nodes.get @get \a_node_id # undefined if new
    b-node   = C.Nodes.get @get \b_node_id # undefined if new
    yyyy     = a-node?get-yyyy! or b-node?get-yyyy!
    when-raw = if yyyy then "#yyyy-#yyyy" else @get \when
    when-obj = W.parse-range when-raw

    _.extend (@toJSON opts),
      a_node_name: a-node?get \name
      b_node_name: b-node?get \name
      a_is_eq    : \eq is @get \a_is
      a_is_lt    : \lt is @get \a_is
      tip        : get-tip!
      when-obj   : when-obj
      when-text  : get-when-text!
      yy         : yyyy?substring 2
      yyyy       : yyyy
      year       : parseInt yyyy

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
  get-is-editable: -> @isNew! or S.get-id! is (@get \meta .create_user_id)

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

extend-user \Signup
extend-user \User

## add factory methods

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
add-factory-method M.User

# helpers

function add-factory-method model then model.create = ->
  create model, it

function create model, id
  (m = new model!).id = id
  m

function extend-user
  M[it] .= extend get-is-admin: -> \admin is @get \role

