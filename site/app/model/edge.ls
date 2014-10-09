B    = require \backbone
_    = require \underscore
Fac  = require \./_factory
Api  = require \../api
C    = require \../collection
Hs   = require \../history
Cons = require \../../lib/model-constraints
W    = require \../../lib/when

m = B.DeepModel.extend do
  urlRoot: Api.edges

  ## core
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

  ## extensions
  is-in-map: (node-ids) ->
    (_.contains node-ids, @get \a_node_id) and (_.contains node-ids, @get \b_node_id)

  ## validation
  labels:
    'a_node_id': 'Actor A'
    'b_node_id': 'Actor B'
  validation:
    'a_node_id': required:yes
    'b_node_id': required:yes
    'a_is'     : required:yes
    'how'      :
      * required: no
      * pattern : Cons.edge.how.regex
        msg     : "How should be #{Cons.edge.how.info}"
    'when':
      * required: no
      * pattern : Cons.edge.when.regex
        msg     : "When should be #{Cons.edge.when.info}"

_create = Fac.get-factory-method m
m.create = ->
  o = _create it
  unless it # auto-populate new edge with 2 last nodes
    o.set \a_node_id, Hs.get-node-id 0
    o.set \b_node_id, Hs.get-node-id 1
    if (edge = Hs.get-edge!) then o.set \how, edge.get \how
  o

module.exports = m
