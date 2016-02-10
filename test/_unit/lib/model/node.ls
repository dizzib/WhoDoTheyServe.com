Assert = require \chai .assert
Node   = require "#{process.cwd!}/site/lib/model/node"

(...) <- describe 'model/node'

it 'is a person' ->
  const NAMES =
    'Maxwell, James Clark'
    'Rothschild, Lyn Forester de (Lady)'
    'Sutherland, Peter D (KCMG)'
    'Tesla, Nikola'
    'Von Braun, Werner'
  for n in NAMES then Assert.ok (Node.is-person n), n

it 'is not a person' ->
  const NAMES =
    'Economist, The (magazine)'
    'Ministry of Economy, Industry and Digital Affairs'
    'Times, The'
  for n in NAMES then Assert.notOk (Node.is-person n), n
