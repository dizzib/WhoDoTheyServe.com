B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
W   = require \../../lib/when
Api = require \../api
C   = require \../collection
Fac = require \./_factory

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
      'a-node' : a-node?toJSON-T!
      'b-node' : b-node?toJSON-T!
      a_is     : @get \a_is
      a_is_eq  : \eq is @get \a_is
      a_is_lt  : \lt is @get \a_is
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

_create = Fac.get-factory-method m
m.create = ->
  o = _create it
  if o.isNew! # pre-populate new edge
    B.tracker.node-ids = _.last B.tracker.node-ids, 2
    o.set \a_is \lt
    o.set \a_node_id B.tracker.node-ids.0
    o.set \b_node_id B.tracker.node-ids.1
  o

module.exports = m
