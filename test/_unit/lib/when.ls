Expect  = require \chai .expect
Subject = require "#{process.cwd!}/site/lib/when"

(...) <- describe 'when ' # trailing space to workaround mocha bug #

it \parse-range, (done) ->
  c = Subject.constants

  const TEST-CASES =
    ## boundaries
    * ''                        c.MIN, c.MAX
    # from-
    * '1000-'                   c.MIN, c.MAX
    * '01/1000-'                c.MIN, c.MAX
    * '01/01/1000-'             c.MIN, c.MAX
    # -to
    * '-2999'                   c.MIN, c.MAX
    * '-12/2999'                c.MIN, c.MAX
    * '-31/12/2999'             c.MIN, c.MAX
    # from-to
    * '1000-2999'               c.MIN, c.MAX
    * '01/1000-31/12/2999'      c.MIN, c.MAX
    * '01/01/1000-31/12/2999'   c.MIN, c.MAX
    * '1000-31/12/2999'         c.MIN, c.MAX
    ## realistic
    * '1996-'                   19960101, c.MAX
    * '-1996'                   c.MIN   , 19961231
    * '2014-2014'               20140101, 20141231
    * '07/2014-07/2014'         20140701, 20140731
    * '21/07/2014-21/07/2014'   20140721, 20140721

  for t in TEST-CASES
    actual = Subject.parse-range t.0
    Expect actual.from .to.equal t.1, t.0
    Expect actual.to   .to.equal t.2, t.0
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
    # bad range
    * 'xxxx-'                , \range
    * '2014-2013'            , \range
    * '07/2014-06/2014'      , \range
    * '22/07/2014-21/07/2014', \range

  for t in TEST-CASES
    Expect(-> Subject.parse-range t.0).to.throw t.1
  done!
