_ = require \underscore

module.exports =
  get-factory-method: (model) ->
    (o) ->
      m = new model!

      # id might be null since backbone 1.1.2 router. For some reason, setting _id = null
      # causes mongo to create a document with _id as an ObjectId.
      return m unless o?

      if _.isString o then m.set \_id, o else if _.isObject o then m.set o
      m
