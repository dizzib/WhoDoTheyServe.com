global.log = console.log

const DB-CACHE = "#{process.cwd!}/site/api/db-cache"

Should   = require \chai .should!
Client   = require \mongodb .MongoClient
Mongoose = require \mongoose
W        = require \wait.for
R        = require \../helper .run
Cache-C  = require "#DB-CACHE/collection-cache"
Cache-Q  = require "#DB-CACHE/query-by-entity-cache"
P-Id     = require "#DB-CACHE/../model/plugin-id"
Store    = require "#DB-CACHE/in-process-store"
Sweeper  = require "#DB-CACHE/sweeper"

(...) <- describe 'db-cache'
@timeout 5000

const DB-URL = \mongodb://localhost/test

var db, C-Foos, M-Foos
ids = {}

Sweeper.create store-c = Store.create!
Sweeper.create store-q = Store.create!
Cache-C.create store-c
Cache-Q.create store-q

before R ->
  Mongoose.connect DB-URL
  drop-db!

  spec =
    tag      : type:String
    entity_id: type:String
    name     : type:String
  schema = new Mongoose.Schema spec
    ..plugin P-Id
  M-Foos := Mongoose.model \foos, schema
  database = W.forMethod Client, \connect, DB-URL

  db := database
  C-Foos := db.collection \foos
  store-c.clear!
  store-q.clear!

after R ->
  drop-db!

# NOTE: each test must leave collection empty for next test
it 'collection cache', (done) ->
  <- add \a, \foo, \andy
  store-c.hit-count.should.equal 0
  <- assert-count 1
  store-c.hit-count.should.equal 1
  <- find-by-id \a
  store-c.hit-count.should.equal 2
  <- add \b, \foo, \butch
  <- add \c, \bar, \chris
  <- assert-count 3
  <- find-by-id-then-save \a, \d
  <- assert-count 3
  <- assert-exists \b
  <- assert-exists \d
  <- find-one-and-update \c, \cindy
  <- find-one-by-name \chris, 0
  <- find-one-by-name \cindy, 1
  <- find-by-id-and-remove \b
  <- assert-not-exists \b
  <- assert-count 2
  <- find-one-then-remove \c
  <- assert-not-exists \c
  <- assert-count 1
  <- find-by-id-and-remove \d
  <- assert-not-exists \d
  <- assert-count 0
  done!

it 'query-by-entity cache', (done) ->
  <- add \a, \foo, \andy
  <- assert-count 1
  <- find-by-entity-id \foo, 1
  store-q.hit-count.should.equal 0
  <- find-by-entity-id \foo, 1
  store-q.hit-count.should.equal 1
  <- find-by-entity-id \bar, 0
  <- add \b, \foo, \butch
  <- add \c, \bar, \chris
  <- assert-count 3
  <- find-by-id-then-save \a, \d
  <- find-by-entity-id \foo, 2
  <- find-by-entity-id \bar, 1
  <- find-by-id-and-remove \b
  <- assert-not-exists \b
  <- assert-count 2
  <- find-by-id-and-remove \c
  <- assert-not-exists \c
  <- assert-count 1
  <- find-one-then-remove \d
  <- assert-not-exists \d
  <- assert-count 0
  done!

## helpers

function add tag, entity-id, name, done
  foo = new M-Foos tag:tag, entity_id:entity-id, name:name
  err, foo <- foo.save
  Should.not.exist err
  ids[tag] = foo._id
  done!

function assert-count n, done
  # find
  err, docs <- M-Foos.find!lean!exec
  Should.not.exist err
  docs.should.have.length n
  # model
  err, count <- M-Foos.count
  Should.not.exist err
  count.should.equal n
  # native
  err, count <- C-Foos.count
  Should.not.exist err
  count.should.equal n
  done!

function assert-exists tag, done
  # cached
  err, foo <- M-Foos.findOne tag:tag .lean!exec
  Should.not.exist err
  Should.exist foo
  # native
  err, foo <- C-Foos.findOne tag:tag
  Should.not.exist err
  Should.exist foo
  done!

function assert-not-exists tag, done
  # cached
  err, foo <- M-Foos.findById ids[tag] .lean!exec
  Should.not.exist err
  Should.not.exist foo
  # native
  err, foo <- C-Foos.findOne tag:tag
  Should.not.exist err
  Should.not.exist foo
  done!

function find-one-and-update tag, name, done
  err, foo <- M-Foos.findOneAndUpdate { tag:tag }, name:name
  Should.not.exist err
  foo.name.should.equal name
  done!

function find-one-then-remove tag, done
  err, foo <- M-Foos.findOne tag:tag
  Should.not.exist err
  err <- foo.remove
  Should.not.exist err
  done!

function find-one-by-name name, n-expect, done
  err, foo <- M-Foos.findOne name:name .lean!exec
  Should.not.exist err
  Should.not.exist foo if n-expect is 0
  Should.exist foo if n-expect is 1
  done!

function find-by-id-and-remove tag, done
  err <- M-Foos.findByIdAndRemove ids[tag]
  Should.not.exist err
  done!

function find-by-entity-id entity-id, n-expect, done
  err, docs <- M-Foos.find entity_id:entity-id .lean!exec
  Should.not.exist err
  Should.exist docs
  docs.should.have.length n-expect
  done!

function find-by-id tag, done
  err, foo <- M-Foos.findById ids[tag] .lean!exec
  Should.not.exist err
  Should.exist foo
  done!

function find-by-id-then-save tag-old, tag-new, done
  err, foo <- M-Foos.findById ids[tag-old]
  Should.not.exist err
  foo.tag = tag-new
  err, foo <- foo.save
  Should.not.exist err
  ids[tag-new] = foo._id
  done!

function drop-db
  W.forMethod Mongoose.connection.db, \executeDbCommand, dropDatabase:1
