Assert = require \chai .assert
Cons   = require "#{process.cwd!}/site/lib/model/constraints"

(...) <- describe 'model/constraints'

it 'edge.when ok' ->
  const WHENS =
    <[ 1000- 2999- 01/1000- 12/2999- 01/01/1000- 31/12/2999-
       -1000 -2999 -01/1000 -12/2999 -01/01/1000 -31/12/2999
       1000-2999 ]>
  for w in WHENS then Assert.ok (Cons.edge.when.regex.test w), w

it 'edge.when bad' ->
  const WHENS =
    <[ a 1 10 100 1000 1900 2000
       a- 1- 10- 100- 999- 0999- 3000- 0/1000- 00/1000- 13/1000- 1/1000-
       -b -2 -20 -200 -999 -3000 -9999
       - a-b 999-3000 2999-3000 ]>
  for w in WHENS then Assert.notOk (Cons.edge.when.regex.test w), w

it 'node.name ok' ->
  const NAMES =
    '21st Century Fox'
    'Bank of England' 'Bank of England, The'
    'Botín, Aná Patricia'
    'Clarke, Kenneth (QC, MP)'
    'EU (European Union)'
    'In-Q-Tel'
    'NASA'
    'News UK (& Ireland Ltd)'
    'Tesla, Nikola'
    'Turner, "Ted"' 'Turner, \'Ted\''
  for n in NAMES then Assert.ok (Cons.node.name.regex.test n), n

it 'node.name bad' ->
  const NAMES =
    'ECB'
    ' NASA' 'NASA ' 'NASA ,' 'NASA )'
    'the Bank of England' 'The Bank of England'
    'tesla, Nikola'
  for n in NAMES then Assert.notOk (Cons.node.name.regex.test n), n

it 'url ok' ->
  const URLS =
    \http://foo.com
    \http://foo.com?bar=boo
  for u in URLS then Assert.ok (Cons.url.regex.test u), u

it 'url bad' ->
  const URLS =
    \foo
    \http://
    \http://foo
    \https://web.archive.org
  for u in URLS then Assert.notOk (Cons.url.regex.test u), u
