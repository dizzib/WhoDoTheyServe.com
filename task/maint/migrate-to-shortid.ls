_   = require \lodash
Mc  = require \mongodb .MongoClient
Sid = require \shortid
W   = require \wait.for
W4  = require \wait.for .for
W4m = require \wait.for .forMethod

#const DB-URI = \mongodb://localhost/wdts_dev
const DB-URI = \mongodb://localhost/wdts_staging

log = console.log
<- W.launchFiber

id-map = {}
db = W4m Mc, \connect, DB-URI
migrate \edges, <[ a_node_id b_node_id ]>
migrate \evidences, <[ entity_id ]>
migrate-hive!
migrate \nodes
migrate \notes, <[ entity_id ]>
migrate \users

db.close!

# helpers

function get-new-id old-id
  return old-id if _.isString old-id and old-id.length is 10
  return new-id if new-id = id-map[old-id]
  function pause cb then _.delay (-> cb!), 100ms
  W4 pause # without this, shortid must add an extra character for uniqueness
  return id-map[old-id] = Sid.generate!

function migrate coll-name, id-field-names = []
  id-field-names.push \_id
  coll = db.collection coll-name
  curs = W4m coll, \find
  while o = W4m curs, \nextObject
    old-id = o._id
    for id-field-name in id-field-names then o[id-field-name] = get-new-id o[id-field-name]
    if o.meta?create_user_id then o.meta.create_user_id = get-new-id o.meta.create_user_id
    save-new coll, o, old-id

function migrate-hive
  coll = db.collection \hive
  curs = W4m coll, \find
  while o = W4m curs, \nextObject
    if o.key is \graph
      value = JSON.parse o.value
      for coord in value.layout then coord.id = get-new-id coord.id
      for image in value.images then image.id = get-new-id image.id
      o.value = JSON.stringify value
    o._id = get-new-id old-id = o._id
    save-new coll, o, old-id

function save-new coll, o, old-id
    log o
    W4m coll, \remove, _id:old-id
    W4m coll, \save, o
