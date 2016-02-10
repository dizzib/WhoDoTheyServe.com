Assert = require \chai .assert
Cons   = require "#{process.cwd!}/site/lib/model/constraints"

(...) <- describe 'model/constraints'

it 'edge.when', (done) ->
  rx = Cons.edge.when.regex

  for good in <[ 1000- 2999-
                 01/1000- 12/2999-
                 01/01/1000- 31/12/2999-
                 -1000 -2999
                 -01/1000 -12/2999
                 -01/01/1000 -31/12/2999
                 1000-2999
              ]>
    Assert.ok (rx.test good), good

  for bad in <[ a 1 10 100 1000 1900 2000
                - a- -b a-b 1- 10- 100- -2 -20 -200
                999- 0999- 3000-
                0/1000- 00/1000- 13/1000-
                1/1000-
                -999 -3000 -9999
                999-3000 2999-3000
             ]>
    Assert.notOk (rx.test bad), bad

  done!
