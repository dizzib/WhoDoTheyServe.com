B   = require \backbone
Api = require \../api

m = B.DeepModel.extend do
  ## core
  toJSON-T: -> @toJSON it

  ## extensions
  get-prop: (name) ->
    if json = @get \value then (JSON.parse json)[name] else void
  set-prop: (name, value) ->
    o = if json = @get \value then (JSON.parse json) else {}
    if value? then o[name] = value else delete o[name]
    @set \value, JSON.stringify o

module.exports =
  Evidences: m.extend urlRoot:"#{Api.hive}/evidences"
  Map      : m.extend urlRoot:"#{Api.hive}/map"
