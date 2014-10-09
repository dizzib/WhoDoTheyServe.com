_  = require \underscore
C  = require \./collection
E  = require \./entities
Hi = require \./history
M  = require \./model
S  = require \./session
W  = require \../lib/when

# extend models with custom methods

add-factory-method M.Session

# helpers

function add-factory-method model then model.create = ->
  create model, it

function create model, id
  (m = new model!)
  # id might be null since backbone 1.1.2 router. For some reason, setting _id = null
  # causes mongo to create a document with _id as an ObjectId.
  m.set \_id, id if id?
  m
