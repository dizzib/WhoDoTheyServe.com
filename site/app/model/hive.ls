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

m-evis = m.extend urlRoot:"#{Api.hive}/evidences"
m-map  = m.extend urlRoot:"#{Api.hive}/map"

evis = new m-evis!
  ..on \sync, -> # set convenience properties
    @dead-ids = @get-prop \dead-ids or []

map  = new m-map!
  ..on \sync, -> # set convenience properties
    v = JSON.parse @get \value
    @default-id = v.default?id

module.exports =
  Evidences: m-evis
  Map      : m-map

  instance:
    Evidences: evis
    Map      : map
