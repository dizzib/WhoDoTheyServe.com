B = require \./_browser
H = require \../spec/helper

h = H \latest void void void void list

const TYPES = <[ map edge node note void ]>
module.exports = {["is#n" {[t, h.get-spec-list n, t] for t in TYPES}] for n from 0 to 9}

function list n, first-type
  B.click \Latest \a
  B.wait-for 'Latest Updates' \legend
  B.assert.count n, sel:\.latest>ul>li
  B.wait-for '' ".latest>ul>li:first-child>.entity>._type-#first-type" if n
