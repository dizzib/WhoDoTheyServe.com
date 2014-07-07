# maintenance task to check all evidence urls and save a list of dead ones
# to the hive, to be highlighted in the app for manual resolution

_     = require \lodash
Chalk = require \chalk
Hive  = require \../../site/api/hive
M     = require \mongoose
Mc    = require \mongodb .MongoClient
Shell = require \shelljs/global
W     = require \wait.for
W4    = require \wait.for .for
W4m   = require \wait.for .forMethod

const DB-URI = \mongodb://localhost/wdts_staging

log       = console.log
dead      = []    # dead evidences
n-max     = 99999 # reduce limit to test
n-pending = 0     # current number of http requests curling

<- W.launchFiber
db = W4m Mc, \connect, DB-URI
coll = db.collection \evidences
curs = W4m coll, \find
while n-max-- > 0 and ev = W4m curs, \nextObject
  W4 pause, 100ms # otherwise we end up with a EMFILE error
  check ev
db.close!

# helpers

function add-dead ev, reason
  log Chalk.red reason
  dead.push ev
  save-if-done!

function check ev
  log url = ev.url
  n-pending++
  try
    code, res <- exec "curl --silent --range 0-499 #url", silent:true
    return add-dead ev, "curl #url exited with code #code" if code > 0
    return add-dead ev, "curl returned nothing from #url" unless res
    log Chalk.green "#url is ok (#{res.length} bytes)"
    save-if-done!
  catch e
    add-dead ev, "#url #{e.message}"

function pause ms, cb
  _.delay cb, ms

function save-if-done
  if --n-pending is 0
    dead-ids = _.pluck dead, \_id
    log value = 'dead-ids':dead-ids
    M.connect DB-URI
    Hive.set \evidences, JSON.stringify value
    M.disconnect!
    log 'DONE!'
