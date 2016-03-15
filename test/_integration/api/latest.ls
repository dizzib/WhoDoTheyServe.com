Chai = require \chai .should!
_    = require \lodash
Http = require \./_http
H    = require \../spec/helper

h = H \latest, void, read, void, void, list

const TYPES = <[ map edge node note void ]>
module.exports = _.extend do
  h.get-spec!
  {["is#n" {[t, h.get-spec-list n, t] for t in TYPES}] for n from 0 to 9}

function list n, first-type
  Http.assert res = Http.get \latest
  (o = res.object).ids.length.should.equal n
  o.ids.0._type.should.equal first-type if n
  o.entities["#{first-type}s"].length.should.be.at.least 1 if n

function read # check integrity
  Http.assert res = Http.get \latest
  ents = (o = res.object).entities
  for {_id, _type} in o.ids
    (_.filter ents["#{_type}s"], _id:_id).length.should.equal 1
