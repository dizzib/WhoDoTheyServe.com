_           = require \lodash
M           = require \mongoose
Cons        = require \../../lib/model/constraints
Crud        = require \../crud
M-Edges     = require \./edges
M-Evidences = require \./evidences
M-Nodes     = require \./nodes
M-Notes     = require \./notes
P-Id        = require \./plugin/id
P-Meta      = require \./plugin/meta

s-node = new M.Schema do
  _id: type:String , required:yes
  x  : type:Number , required:no # optional since node may be filtered out of d3
  y  : type:Number , required:no # optional since node may be filtered out of d3
  pin: type:Boolean, required:no # optional since most nodes won't be pinned

s-size =
  x: type:Number, required:yes
  y: type:Number, required:yes

schema = new M.Schema do
  name            : type:String, required:yes, match:Cons.map.name.regex
  description     : type:String, required:no , match:Cons.map.description.regex
  when            : type:String, required:no , match:Cons.map.when.regex
  edge_cutoff_date: type:Date  , default:Date.now # exclude edges created after this cutoff
  node_default_rx : type:String, required:no # regular-expression string
  nodes           : [s-node]
  size            : s-size
  flags           :
    private       : type:Boolean, required:no

schema
  ..plugin P-Id
  ..plugin P-Meta

module.exports = me = Crud.set-fns (M.model \maps schema)
  ..crud-fns
    ..read = read
    ..list = (req, res, next) ->
      err, maps <- me.find!lean!exec
      return next err if err
      res.json [_.pick map, <[ _id name meta ]> for map in _.filter maps, ->
        not(it.flags?private) or req.session.signin?id is it.meta.create_user_id]

# helpers

# return all entities required to render just this map
# to improve performance when hitting the site for the first time
function read req, res, next
  err, map <- me.findById req.id .lean!exec
  return next err if err
  return res.json {} unless map
  ## !!! server-side version of client-side view/map/graph.refresh-entities
  err, nodes <- M-Nodes.find!lean!exec
  return next err if err
  map.entities = ents = {}
  ents.nodes = _.intersectionBy nodes, map.nodes, \_id
  err, edges <- M-Edges.find!lean!exec
  return next err if err
  map-node-ids = _.map map.nodes, \_id
  ents.edges = _.filter edges, ->
    return false unless (it.a_node_id in map-node-ids) and (it.b_node_id in map-node-ids)
    return true unless edge-cutoff-date = map.edge_cutoff_date
    # exclude edges created by other users after the cutoff
    it.meta.create_date < edge-cutoff-date or it.meta.create_user_id is map.meta.create_user_id
  nodes-and-edges = ents.nodes ++ ents.edges
  err, ents.evidences <- M-Evidences.find-for-entities nodes-and-edges
  return next err if err
  err, ents.notes <- M-Notes.find-for-entities nodes-and-edges
  return next err if err
  res.json map
