B    = require \backbone
Api  = require \./api
Cons = require \../lib/model-constraints

B.Model.prototype.idAttribute = \_id # mongodb

Model = B.DeepModel.extend do
  toJSON-T: (opts) -> @toJSON opts

Model-hive = Model.extend do
  get-prop: (name) ->
    if json = @get \value then (JSON.parse json)[name] else void
  set-prop: (name, value) ->
    o = if json = @get \value then (JSON.parse json) else {}
    if value? then o[name] = value else delete o[name]
    @set \value, JSON.stringify o

module.exports =
  Evidence: Model.extend do
    urlRoot   : Api.evidences
    labels    : 'url': 'Url'
    validation: 'url': required:yes pattern:\url
  Edge: Model.extend do
    urlRoot: Api.edges
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
  Hive:
    Evidences: Model-hive.extend urlRoot:"#{Api.hive}/evidences"
    Map      : Model-hive.extend urlRoot:"#{Api.hive}/map"
  Map: Model.extend do
    urlRoot: Api.maps
    validation:
      'description':
        * required: no
        * pattern : Cons.map.description.regex
          msg     : "Description should be #{Cons.map.description.info}"
      'name':
        * required: yes
        * pattern : Cons.map.name.regex
          msg     : "Name should be #{Cons.map.name.info}"
      'when':
        * required: no
        * pattern : Cons.map.when.regex
          msg     : "When should be #{Cons.map.when.info}"
  Node: Model.extend do
    urlRoot: Api.nodes
    validation:
      'name':
        * required: yes
        * pattern : Cons.node.name.regex
          msg     : "Name should be #{Cons.node.name.info}"
  Note: Model.extend do
    urlRoot: Api.notes
    validation:
      'text':
        * required: yes
        * pattern : Cons.note.regex
          msg     : "Note should be #{Cons.note.info}"
  Session: Model.extend do
    urlRoot: Api.sessions
    labels:
      'handle': 'Username'
    validation:
      'handle'  : required:yes
      'password': required:yes
  Sys: Model.extend do
    urlRoot:Api.sys
  User: Model.extend do
    urlRoot: Api.users
    labels:
      'info'    : 'Homepage'
      'passconf': 'Confirm Password'
    validation:
      'handle':
        * required: yes
        * pattern : Cons.handle.regex
          msg     : "Username should be #{Cons.handle.info}"
      'password':
        * required: -> @isNew!
        * pattern : Cons.password.regex
          msg     : "Password should be #{Cons.password.info}"
      'passconf':
        equalTo: \password
      'email':
        * required: no
        * pattern : Cons.email.regex
          msg     : "Email should be #{Cons.email.info}"
      'info':
        pattern : \url
        required: no
