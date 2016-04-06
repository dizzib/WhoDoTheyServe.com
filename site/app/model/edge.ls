B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
W   = require \../../lib/when
Api = require \../api
C   = require \../collection
Fac = require \./_factory

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.edges

  ## core
  toJSON-T: (opts) ->
    ~function get-tip
      "Evidence #{if how = @get \how then "- #how" else ''} #{get-when-text true}".trim!

    function get-when-text is-tip
      return '' if yyyy and not is-tip
      return "in #yyyy" if yyyy
      s = "from #{when-obj.raw.from or '?'}"
      s + if (when-to = when-obj.raw.to) then " to #when-to" else ''

    if nodes = opts?nodes-json-by-id
      a-node = nodes[@get \a_node_id]
      b-node = nodes[@get \b_node_id]
    else
      a-node = C.Nodes.get(@get \a_node_id)?toJSON-T! # undefined if new
      b-node = C.Nodes.get(@get \b_node_id)?toJSON-T! # undefined if new
    yyyy     = a-node?name-yyyy or b-node?name-yyyy
    when-obj = W.parse-range @get \when

    _.extend (@toJSON opts),
      a_node   : a-node
      b_node   : b-node
      a_is     : a-is = @get \a_is
      a_is_eq  : \eq is a-is
      a_is_lt  : \lt is a-is
      tip      : get-tip!
      when-obj : when-obj
      when-text: get-when-text!
      yy       : yyyy?substring 2
      yyyy     : yyyy
      year     : parseInt yyyy

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
      * pattern : Con.edge.how.regex
        msg     : "How should be #{Con.edge.how.info}"
    'when':
      * required: no
      * pattern : Con.edge.when.regex
        msg     : "When should be #{Con.edge.when.info}"

_create = Fac.get-factory-method me
me.create = ->
  o = _create it
  if o.isNew! # pre-populate new edge
    B.tracker.node-ids = _.last B.tracker.node-ids, 2
    o.set \a_is \lt
    o.set \a_node_id B.tracker.node-ids.0
    o.set \b_node_id B.tracker.node-ids.1
  o
