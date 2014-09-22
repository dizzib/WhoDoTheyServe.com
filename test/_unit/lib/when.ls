Expect  = require \chai .expect
Subject = require "#{process.cwd!}/site/lib/when"

(...) <- describe 'when ' # trailing space to workaround mocha bug #

const MIN = 10000101
const MAX = 29991231

it \is-in-range, (done) ->
  const TEST-CASES =
    * no , 20100606, [19500320 20100605]
    * yes, 20100606, [19500320 20100606]
    * yes, 20100606, [20100606 20121013]
    * no , 20100606, [20100607 20121013]

  for t in TEST-CASES
    actual = Subject.is-in-range t.1, {from:t.2.0, to:t.2.1}
    Expect actual .to.equal t.0
  done!

it \is-overlap-ranges, (done) ->
  const TEST-CASES =
    # earlier, later
    * no , [19500320 20000605], [20100606 20121013] # apart
    * no , [19500320 20100605], [20100606 20121013] # adjacent
    * yes, [19500320 20100606], [20100606 20121013] # 1 day overlap
    * yes, [19500320 20110606], [20100605 20121013] # 1 year overlap
    * yes, [19500320 20500606], [20100606 20121013] # encompass
    # later, earlier
    * no , [20100606 20121013], [19500320 20000605] # apart
    * no , [20100606 20121013], [19500320 20100605] # adjacent
    * yes, [20100606 20121013], [19500320 20100606] # 1 day overlap
    * yes, [20100605 20121013], [19500320 20110606] # 1 year overlap
    * yes, [20100606 20121013], [19500320 20500606] # encompass

  for t in TEST-CASES
    actual = Subject.is-overlap-ranges {from:t.1.0, to:t.1.1}, {from:t.2.0, to:t.2.1}
    Expect actual .to.equal t.0
  done!

it \parse-range, (done) ->
  c = Subject.constants

  const TEST-CASES =
    ## boundaries
    * ''                        MIN, MAX
    # from-
    * '1000-'                   MIN, MAX
    * '01/1000-'                MIN, MAX
    * '01/01/1000-'             MIN, MAX
    # -to
    * '-2999'                   MIN, MAX
    * '-12/2999'                MIN, MAX
    * '-31/12/2999'             MIN, MAX
    # from-to
    * '1000-2999'               MIN, MAX
    * '01/1000-31/12/2999'      MIN, MAX
    * '01/01/1000-31/12/2999'   MIN, MAX
    * '1000-31/12/2999'         MIN, MAX
    ## realistic
    * '1996-'                   19960101, MAX
    * '-1996'                   MIN     , 19961231
    * '2014-2014'               20140101, 20141231
    * '07/2014-07/2014'         20140701, 20140731
    * '21/07/2014-21/07/2014'   20140721, 20140721

  for t in TEST-CASES
    actual = Subject.parse-range t.0
    Expect actual.int.from .to.equal t.1, t.0
    Expect actual.int.to   .to.equal t.2, t.0
  done!

it \parse-range-exceptions, (done) ->
  const TEST-CASES =
    # must have a single dash
    * '--'  , \dash
    * '0-1-', \dash
    * '2014', \dash
    # bad length
    * '100-'      , \length
    * '-100'      , \length
    * '7/2014-'   , \length
    * '4/12/2014-', \length
    * '14/2/2014-', \length
    # bad range
    * 'xxxx-'                , \range
    * '2014-2013'            , \range
    * '07/2014-06/2014'      , \range
    * '22/07/2014-21/07/2014', \range

  for t in TEST-CASES
    Expect(-> Subject.parse-range t.0).to.throw t.1
  done!
