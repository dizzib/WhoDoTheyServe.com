Assert = require \assert

const MIN = day:\01 month:\01 year:\1000
const MAX = day:\31 month:\12 year:\2999

module.exports = me =
  constants:
    when:
      MIN: 10000101
      MAX: 29991231

  parse-when: ->
    c = me.constants.when
    return from:c.MIN, to:c.MAX unless it

    w = it.split \-
    Assert w.length is 2, "'#it' must contain a single dash"

    w-from = get-datenum w.0, MIN
    w-to   = get-datenum w.1, MAX

    Assert w-from <= w-to, "Invalid range from #w-from to #w-to"
    return from:w-from, to:w-to

    function get-datenum str, defaults
      arr = if str then str.split \/ else [defaults.year]
      l   = arr.length
      arr.unshift defaults.month if l is 1
      arr.unshift defaults.day   if l in [1, 2]
      [dd, mm, yyyy] = [arr.0, arr.1, arr.2]
      s = "#yyyy#mm#dd"
      Assert s.length is 8, "Invalid when.length = #{s.length}, should be 8"
      parseInt s
