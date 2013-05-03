Should   = require \chai .should!
Client   = require \mongodb .MongoClient
Mongoose = require \mongoose
Cache-C  = require \../../../api/db-cache/collection-cache
Cache-Q  = require \../../../api/db-cache/query-by-entity-cache
Store    = require \../../../api/db-cache/in-process-store
Sweeper  = require \../../../api/db-cache/sweeper

test = it

describe 'db-cache' ->
  @timeout 5000

  var db, C-Foos, M-Foos
  ids = {}

  Sweeper.create store-c = Store.create!
  Sweeper.create store-q = Store.create!
  Cache-C.create store-c
  Cache-Q.create store-q

  before (done) ->
    const DB-URL = \mongodb://localhost/test

    Mongoose.connect DB-URL
    err <- Mongoose.connection.db.executeDbCommand dropDatabase:1
    return done err if err

    M-Foos := Mongoose.model \foos, new Mongoose.Schema do
      tag      : type:String
      entity_id: type:String
    err, database <- Client.connect DB-URL
    return done err if err

    db := database
    C-Foos := db.collection \foos
    store-c.clear!
    store-q.clear!
    done!

  after (done) ->
    Mongoose.disconnect!
    db.close!
    done!

  # NOTE: each test must leave collection empty for next test
  test 'collection cache', (done) ->
    <- add \a, \foo
    store-c.hit-count.should.equal 0
    <- assert-count 1
    store-c.hit-count.should.equal 1
    <- find-by-id \a
    store-c.hit-count.should.equal 2
    <- add \b, \foo
    <- add \c, \bar
    <- assert-count 3
    <- find-by-id-and-update \a, \d
    <- assert-count 3
    <- assert-exists \b
    <- assert-exists \d
    <- find-by-id-and-remove \b
    <- assert-not-exists \b
    <- assert-count 2
    <- find-one-and-remove \c
    <- assert-not-exists \c
    <- assert-count 1
    <- find-by-id-and-remove \d
    <- assert-not-exists \d
    <- assert-count 0
    done!

  test 'query-by-entity cache', (done) ->
    <- add \a, \foo
    <- assert-count 1
    <- find-by-entity-id \foo, 1
    store-q.hit-count.should.equal 0
    <- find-by-entity-id \foo, 1
    store-q.hit-count.should.equal 1
    <- find-by-entity-id \bar, 0
    <- add \b, \foo
    <- add \c, \bar
    <- assert-count 3
    <- find-by-id-and-update \a, \d
    <- find-by-entity-id \foo, 2
    <- find-by-entity-id \bar, 1
    <- find-by-id-and-remove \b
    <- assert-not-exists \b
    <- assert-count 2
    <- find-by-id-and-remove \c
    <- assert-not-exists \c
    <- assert-count 1
    <- find-one-and-remove \d
    <- assert-not-exists \d
    <- assert-count 0
    done!

  function add tag, entity-id, done then
    foo = new M-Foos tag:tag, entity_id:entity-id
    err, foo <- foo.save
    ids[tag] = foo._id
    return done err if err
    done!

  function assert-count n, done then
    # find
    err, docs <- M-Foos.find!lean!exec
    return done err if err
    docs.should.have.length n
    # model
    err, count <- M-Foos.count
    return done err if err
    count.should.equal n
    # native
    err, count <- C-Foos.count
    return done err if err
    count.should.equal n
    done!

  function assert-exists tag, done then
    # cached
    err, foo <- M-Foos.findOne tag:tag .lean!exec
    return done err if err
    Should.exist foo
    # native
    err, foo <- C-Foos.findOne tag:tag
    return done err if err
    Should.exist foo
    done!

  function assert-not-exists tag, done then
    # cached
    err, foo <- M-Foos.findById ids[tag] .lean!exec
    return done err if err
    Should.not.exist foo
    # native
    err, foo <- C-Foos.findOne tag:tag
    return done err if err
    Should.not.exist foo
    done!

  function find-one-and-remove tag, done then
    err, foo <- M-Foos.findOne tag:tag
    return done err if err
    err <- foo.remove
    return done err if err
    done!

  function find-by-id-and-remove tag, done then
    err <- M-Foos.findByIdAndRemove ids[tag]
    return done err if err
    done!

  function find-by-entity-id entity-id, n-expect, done then
    err, docs <- M-Foos.find entity_id:entity-id .lean!exec
    return done err if err
    Should.exist docs
    docs.should.have.length n-expect
    done!

  function find-by-id tag, done then
    err, foo <- M-Foos.findById ids[tag] .lean!exec
    return done err if err
    Should.exist foo
    done!

  function find-by-id-and-update tag-old, tag-new, done then
    err, foo <- M-Foos.findById ids[tag-old]
    return done err if err
    foo.tag = tag-new
    err, foo <- foo.save
    ids[tag-new] = foo._id
    return done err if err
    done!
