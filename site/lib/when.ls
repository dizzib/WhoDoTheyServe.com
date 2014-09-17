Assert = require \assert

const MIN = day:\01 month:\01 year:\1000
const MAX = day:\31 month:\12 year:\2999
const RX =
  day  : '(0[1-9]|[12]\\d|3[01])'
  month: '(0[1-9]|1[012])'
  year : '[12]\\d\\d\\d'

module.exports = me =
  constants:
    MIN: 10000101
    MAX: 29991231
    RX : "((#{RX.month}\\/)|(#{RX.day}\\/#{RX.month}\\/))?#{RX.year}"

  parse: (str, defaults = MIN) ->
    arr = if str then str.split \/ else [defaults.year]
    l   = arr.length
    arr.unshift defaults.month if l is 1
    arr.unshift defaults.day   if l in [1, 2]
    [dd, mm, yyyy] = [arr.0, arr.1, arr.2]
    s = "#yyyy#mm#dd"
    Assert s.length is 8, "Invalid when.length = #{s.length}, should be 8"
    parseInt s

  parse-range: ->
    c = me.constants
    return from:c.MIN, to:c.MAX unless it
    w = it.split \-
    Assert w.length is 2, "'#it' must contain a single dash"
    w-from = me.parse w.0, MIN
    w-to   = me.parse w.1, MAX
    Assert w-from <= w-to, "Invalid range from #w-from to #w-to"
    from:w-from, to:w-to
