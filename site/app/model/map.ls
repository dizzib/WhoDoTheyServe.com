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
  globalise-entities: -> # should be called shortly after parsing
    return unless json = @get(\entities)?json
    C.Nodes.set json.nodes, remove:false # add nodes first so edge comparator can read node names
    C.Edges.set json.edges, remove:false
    C.Evidences.set json.evidences, remove:false
    C.Notes.set json.notes, remove:false
  parse: -> # only parse core entities for performance
    if json = it.entities then it.entities =
      nodes: new C.nodes json.nodes
      edges: new C.edges json.edges
      json: json
    it
  parse-secondary-entities: -> # split away from core parse for performance
    if json = (ents = @get \entities)?json
      ents.evidences ||= new C.evidences json.evidences
      ents.notes ||= new C.notes json.notes

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
