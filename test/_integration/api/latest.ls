Chai = require \chai .should!
Http = require \./_http
H    = require \../spec/helper

h = H \latest void void void void list

const TYPES = <[ map edge node note void ]>
module.exports = {["is#n" {[t, h.get-spec-list n, t] for t in TYPES}] for n from 0 to 9}

function list n, first-type
  Http.assert res = Http.get \latest
  res.object.ids.length.should.equal n
  res.object.ids.0._type.should.equal first-type if n
  res.object.entities["#{first-type}s"].length.should.be.at.least 1 if n
