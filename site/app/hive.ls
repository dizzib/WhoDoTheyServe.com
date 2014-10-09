H = require \./helper
M = require \./model

map = new (M.Hive.Map)!
  ..on \sync, -> # set convenience properties
    v = JSON.parse @get \value
    @default-id = v.default?id

module.exports = me =
  Evidences: new (M.Hive.Evidences)!
  Map      : map
