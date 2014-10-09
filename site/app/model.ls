B      = require \backbone
Api    = require \./api
Cons   = require \../lib/model-constraints
M-Edge = require \./model/edge
M-Evi  = require \./model/evidence
M-Hive = require \./model/hive
M-Map  = require \./model/map
M-Node = require \./model/node
M-Note = require \./model/note

Model = B.DeepModel.extend do
  toJSON-T: (opts) -> @toJSON opts

module.exports =
  Evidence: M-Evi
  Edge    : M-Edge
  Map     : M-Map
  Node    : M-Node
  Note    : M-Note
  Hive    : M-Hive

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
