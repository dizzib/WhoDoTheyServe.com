_    = require \lodash
Cons = require "#{process.cwd!}/site/lib/model-constraints"
H    = require \./helper

exports.get-spec = (...args) ->
  const DMY1 = '20/10/1980'
  const  MY1 =    '10/1980'
  const   Y1 =       '1980'
  const DMY2 = '31/10/1990'
  const DMY3 = '01/11/1990'
  const DMY4 = '30/06/2014'
  const DMY5 = '01/07/2014'

  h = H \edge ...args

  function get-spec-ab fields then h.get-spec \ab fields
  function get-spec-ac fields then h.get-spec \ac fields
  function get-spec-ba fields then h.get-spec \ba fields
  function get-spec-bc fields then h.get-spec \bc fields

  ab: _.extend do
    get-spec-ab!
    is:
      eq: get-spec-ab a_is:\eq
      gt: get-spec-ab a_is:\gt
      lt: get-spec-ab a_is:\lt
    how:
      number: get-spec-ab how:'7 voting members'
      symbol: get-spec-ab how:'founder, co-chair &/or CEO'
      max   : get-spec-ab how:\x * 50
      max-gt: get-spec-ab how:\x * 51
      min   : get-spec-ab how:\xx
      min-lt: get-spec-ab how:\x
    when:
      null: get-spec-ab when:''
      from:
        dmy: get-spec-ab when:"#DMY1-"
        my : get-spec-ab when:"#MY1-"
        y  : get-spec-ab when:"#Y1-"
        bad: get-spec-ab when:'32/10/2000-'
      to:
        dmy: get-spec-ab when:"-#DMY1"
        my : get-spec-ab when:"-#MY1"
        y  : get-spec-ab when:"-#Y1"
        bad: get-spec-ab when:'-01/13/2000'
      DMY1-DMY2: get-spec-ab when:"#DMY1-#DMY2"
      DMY2-DMY1: get-spec-ab when:"#DMY2-#DMY1"
    to-aa: get-spec-ab key:\aa
    to-ab: get-spec-ab key:\ab
    to-ba: get-spec-ab key:\ba
  ab2: _.extend do
    DMY2-DMY4: get-spec-ab when:"#DMY2-#DMY4"
    DMY3-DMY4: get-spec-ab when:"#DMY3-#DMY4"
  aa: h.get-spec \aa
  ac: _.extend do
    get-spec-ac!
    to-bc: get-spec-ac key:\bc # update a_node
    to-ad: get-spec-ac key:\ad # update b_node
  ba: _.extend do
    get-spec-ba!
    DMY4_: get-spec-ba when:"#DMY4-"
    DMY5_: get-spec-ba when:"#DMY5-"
  bc: h.get-spec \bc
  ca: h.get-spec \ca
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2
    is3: h.get-spec-list 3
    is4: h.get-spec-list 4
    is5: h.get-spec-list 5
