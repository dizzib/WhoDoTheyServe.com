Chai = require \chai .should!
_    = require \lodash
Http = require \./_http
Sh   = require \../spec/helper

h = Sh \latest, void, read, void, void, list

module.exports =
  is0: h.get-spec-list 0
  is1: h.get-spec-list 1
  is2: h.get-spec-list 2
  is3: h.get-spec-list 3
  is4: h.get-spec-list 4
  is5: h.get-spec-list 5

  type:
    edge: h.get-spec '' type:\edge
    map : h.get-spec '' type:\map
    node: h.get-spec '' type:\node
    note: h.get-spec '' type:\note

function list n
  Http.assert res = Http.get \latest
  res.object.ids.length.should.equal n

function read key, is-ok, fields
  Http.assert (res = Http.get \latest), is-ok
  (type = res.object.ids.0._type).should.equal fields.type
  res.object.entities["#{type}s"].length.should.be.at.least 1
