Assert = require \chai .assert
Node   = require "#{process.cwd!}/site/lib/model/node"

(...) <- describe 'model/node'

it 'is a person' ->
  const NAMES =
    'Botín, Aná Patricia'
    'Clarke, Kenneth (QC, MP)'
    'Maxwell, James Clerk'
    'Rothschild, Lyn Forester de (Lady)'
    'Sutherland, Peter D (KCMG)'
    'Svanberg, Carl-Henric'
    'Tesla, Nikola'
    'Von Braun, Wernher' 'Von-Braun, Wernher'
  for n in NAMES then Assert.ok (Node.is-person n), n

it 'is not a person' ->
  const NAMES =
    'Economist, The (magazine)'
    'Ministry of Economy, Industry and Digital Affairs'
    'Times, The'
  for n in NAMES then Assert.notOk (Node.is-person n), n
