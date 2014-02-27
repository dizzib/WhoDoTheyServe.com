Should = require \chai .should!
Store  = require "#{process.cwd!}/site/api/db-cache/in-process-store"

(...) <- describe 'db-cache/in-process-store'

it 'multi-instance', (done) ->
  store1 = Store.create!
  store2 = Store.create!
  store1.set \a, \foo, 1
  Should.not.exist store2.get \a, \foo
  done!

it 'get/set', (done) ->
  store = Store.create!
  store.set \a, \foo, [ 1, 2 ]
  store.set \b, \foo, 3
  store.hit-count.should.equal 0
  store.miss-count.should.equal 0
  store.get(\a, \foo) .0.should.equal 1
  store.get(\a, \foo) .1.should.equal 2
  store.get(\b, \foo) .should.equal 3
  Should.not.exist store.get \b, \bar
  store.hit-count.should.equal 3
  store.miss-count.should.equal 1
  done!

it 'clear', (done) ->
  store = Store.create!

  store.clear!
  store.clear \a
  store.clear \a, \foo

  store.set \a, \foo, 1
  store.set \a, \bar, 2
  store.set \b, \foo, 3
  store.set \b, \bar, 4
  store.set \c, \foo, 5
  store.set \c, \bar, 6

  store.clear \a, \foo
  Should.not.exist store.get \a, \foo
  store.get \a, \bar .should.equal 2
  store.get \b, \foo .should.equal 3
  store.get \b, \bar .should.equal 4
  store.get \c, \foo .should.equal 5
  store.get \c, \bar .should.equal 6

  store.clear \b

  Should.not.exist store.get \a, \foo
  store.get \a, \bar .should.equal 2
  Should.not.exist store.get \b, \foo
  Should.not.exist store.get \b, \bar
  store.get \c, \foo .should.equal 5
  store.get \c, \bar .should.equal 6

  store.clear!

  Should.not.exist store.get \a, \foo
  Should.not.exist store.get \a, \bar
  Should.not.exist store.get \b, \foo
  Should.not.exist store.get \b, \foo
  Should.not.exist store.get \c, \bar
  Should.not.exist store.get \c, \bar

  done!
