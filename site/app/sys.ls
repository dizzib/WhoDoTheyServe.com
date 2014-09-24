M = require \./model

module.exports = me = new (M.Sys)!
  ..on \sync, ->
    me.env = me.get \env # set Sys.env for convenience
