_ = require \underscore
H = require \./helper
S = require \../state
N = require \../spec/note

module.exports = N.get-spec create, read, update, remove, list

function create done, name, is-ok, fields then
  entity = get-entity name
  note = entity_id: entity._id
  err, res, note <- H.post get-route!, _.extend note, fields
  H.assert res, is-ok
  if H.is-ok res then (S.notes ?= {})[name] = note
  done err

function read done, name, is-ok, fields then
  throw new Error 'require > 0 fields to assert' unless fields
  err, res, json <- H.get get-route name
  note = JSON.parse json
  H.assert res, is-ok
  for k, v of fields then note[k].should.equal v
  done err

function remove done, name, is-ok then
  err, res, node <- H.del get-route name
  H.assert res, is-ok
  if H.is-ok res then delete S.notes[name]
  done err

function update done, name, is-ok, fields then
  note = _id: S.notes[name]._id
  err, res, note <- H.put get-route(name), _.extend note, fields
  H.assert res, is-ok
  if H.is-ok res then S.notes[name] = note
  done err

function list done, name, n then
  H.list done, "notes/for/#{get-entity name ._id}", n

function get-route key then
  return "notes/#{S.notes[key]._id}" if key
  \notes

function get-entity name then
  if name.length is 1 then S.nodes[name] else H.edges[name]
