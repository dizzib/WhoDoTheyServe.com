B      = require \backbone
Api    = require \./api
Cons   = require \../lib/model-constraints
M-Edge = require \./model/edge
M-Evi  = require \./model/evidence
M-Hive = require \./model/hive
M-Map  = require \./model/map
M-Node = require \./model/node
M-Note = require \./model/note
M-User = require \./model/user

Model = B.DeepModel.extend do
  toJSON-T: (opts) -> @toJSON opts

module.exports =
  Evidence: M-Evi
  Edge    : M-Edge
  Map     : M-Map
  Node    : M-Node
  Note    : M-Note
  Hive    : M-Hive
  User    : M-User

  Session: Model.extend do
    urlRoot: Api.sessions
    labels:
      'handle': 'Username'
    validation:
      'handle'  : required:yes
      'password': required:yes
  Sys: Model.extend do
    urlRoot:Api.sys
