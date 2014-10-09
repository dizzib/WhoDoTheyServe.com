module.exports =
  get-factory-method: (model) ->
    (id) ->
      m = new model!
      # id might be null since backbone 1.1.2 router. For some reason, setting _id = null
      # causes mongo to create a document with _id as an ObjectId.
      m.set \_id, id if id?
      m
