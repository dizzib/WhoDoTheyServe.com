B      = require \backbone
_      = require \underscore
Con    = require \../../lib/model/constraints
Api    = require \../api
C      = require \../collection
S      = require \../session
Fac    = require \./_factory
M-Edge = require \./edge
M-Evi  = require \./evidence
M-Node = require \./node
M-Note = require \./note

m = B.DeepModel.extend do
  urlRoot: Api.maps

  ## core
  toJSON-T: -> @toJSON it

  ## extensions
  get-is-editable : -> @isNew! or S.get-id! is (@get \meta .create_user_id)
  parse: ->
    return it unless es = it.entities
    it.entities = ents = # convert json to model instances for view/map
      edges    : _.map es.edges    , -> new M-Edge it
      evidences: _.map es.evidences, -> new M-Evi it
      nodes    : _.map es.nodes    , -> new M-Node it
      notes    : _.map es.notes    , -> new M-Note it
    # add entities to global collections
    C.Nodes.set ents.nodes, remove:false # add nodes first so edge comparator can read node names
    C.Edges.set ents.edges, remove:false
    C.Evidences.set ents.evidences, remove:false
    C.Notes.set ents.notes, remove:false
    it

  ## validation
  validation:
    'description':
      * required: no
      * pattern : Con.map.description.regex
        msg     : "Description should be #{Con.map.description.info}"
    'name':
      * required: yes
      * pattern : Con.map.name.regex
        msg     : "Name should be #{Con.map.name.info}"
    'nodes': ->
      'At least one actor must be selected' unless it?length
    'when':
      * required: no
      * pattern : Con.map.when.regex
        msg     : "When should be #{Con.map.when.info}"

m.create = Fac.get-factory-method m

module.exports = m
