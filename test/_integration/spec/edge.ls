_    = require \lodash
Cons = require "#{process.cwd!}/site/lib/model-constraints"
H    = require \./helper

exports.get-spec = (...args) ->
  h = H \edge, ...args

  function get-spec-ab fields then h.get-spec \ab, fields
  function get-spec-ac fields then h.get-spec \ac, fields
  function get-spec-bc fields then h.get-spec \bc, fields

  ab: _.extend do
    get-spec-ab!
    is:
      eq: get-spec-ab a_is:\eq
      gt: get-spec-ab a_is:\gt
      lt: get-spec-ab a_is:\lt
    how:
      amp   : get-spec-ab how:'is founder & CEO'
      caps  : get-spec-ab how:'Honorary European Chairman'
      comma : get-spec-ab how:'is founder, CEO'
      number: get-spec-ab how:'7 voting members'
      slash : get-spec-ab how:'is founder/CEO'
      max   : get-spec-ab how:\x * 50
      max-gt: get-spec-ab how:\x * 51
      min   : get-spec-ab how:\xx
      min-lt: get-spec-ab how:\x
    year:
      from:
        null  : get-spec-ab year_from:''
        max   : get-spec-ab year_from:Cons.edge.year.max
        max-gt: get-spec-ab year_from:Cons.edge.year.max + 1
        min   : get-spec-ab year_from:Cons.edge.year.min
        min-lt: get-spec-ab year_from:Cons.edge.year.min - 1
      range:
        in : get-spec-ab year_from:2013 year_to:2013
        out: get-spec-ab year_from:2013 year_to:2012
    to-ab: get-spec-ab key:\ab
    to-ba: get-spec-ab key:\ba
  aa: h.get-spec \aa
  ac: _.extend do
    get-spec-ac!
    to-bc: get-spec-ac key:\bc # update a_node
    to-ad: get-spec-ac key:\ad # update b_node
  ba: h.get-spec \ba
  bc: h.get-spec \bc
  ca: h.get-spec \ca
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2
    is3: h.get-spec-list 3
