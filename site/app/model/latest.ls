B   = require \backbone
Api = require \../api
C   = require \../collection

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.latest

  ## core
  toJSON-T: ->
    coll = switch @get \_type
      | \edge => C.Edges
      | \map  => C.Maps
      | \node => C.Nodes
      | \note => C.Notes
    id = @get \_id
    coll.get id .toJSON-T!
