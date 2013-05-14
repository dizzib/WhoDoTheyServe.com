CP       = require \child_process
M        = require \mongoose
N        = require \net
_        = require \underscore
DB       = require \../../api/db
B        = require \./app/browser
H        = require \./api/helper
Evidence = require \./api/evidence
Edge     = require \./api/edge
Node     = require \./api/node
Note     = require \./api/note
Session  = require \./api/session
User     = require \./api/user

unless (env = process.env.NODE_ENV) is \test
  throw new Error "unexpected environment #{env}"

test = it

describe 'api', ->
  @timeout 20000

  before (done) ->
    <- kill-site
    <- drop-db
    DB.connect!
    site = spawn-site!
    site.stderr.on \data, -> H.log "#{it}"
    site.stdout.on \data, ->
      #H.log "#{it}"
      done! if /listening/.test it

  after (done) ->
    <- kill-site
    spawn-site detached:true stdio:\inherit
    done!

  describe 'public', ->
  describe 'signup', ->
    run User.list.is0
    run User.admin.create.ok
    run User.admin.create.bad
    run User.login.min.create.bad
    run Session.admin.signin.password.a.ok
    run User.login.min.create.ok
    run User.login.max.create.ok
    run User.login.num4.create.ok
    run User.login.num3.create.ok
    run User.login.num2.create.bad
    run User.login.num1.create.bad
    run User.login.min-lt.create.bad
    run User.login.max-gt.create.bad
    run User.login.has-space.create.bad
    run User.login.has-ucase.create.bad
    run User.login.has-hyphen.create.bad
    run User.login.min.remove.ok
    run User.login.max.remove.ok
    run User.login.num4.remove.ok
    run User.login.num3.remove.ok
    #run Session.admin.signin.password.a.bad
    #run User.admin.token.fake.verify.bad
    #run User.admin.verify.ok
    #run User.admin.verify.bad
    run User.a.create.ok
    run User.a.email.new.update.ok
    run User.a.email.new.read.ok
    run User.a.create.bad
    run User.b.create.ok
    run User.c.create.ok
    run User.d.create.ok
    run User.list.is5
    run User.e.create.bad      # daily signup max
    run Session.signout.ok
  describe 'user A', ->
    run Session.a.signin.bad.login
    run Session.a.signin.bad.password
    #run Session.a.signin.password.a.bad
    #run User.a.verify.ok
    run Session.a.signin.password.a.ok
    describe 'maint', ->
      run User.a.trust-level.six.update.bad
      run User.a.password.b.update.ok
      run User.a.email.null.update.bad
      run User.a.email.no-domain.update.bad
      run User.a.email.no-dot.update.bad
      run User.a.email.no-name.update.bad
      run User.a.email.mailto.update.bad
      run User.a.email.new.update.ok
      run User.a.email.new.read.ok
      run User.a.info.no-http.update.bad
      run User.a.info.no-path.update.bad
      run User.a.info.no-domain.update.bad
      run User.a.info.path.update.ok
      run User.a.info.path.read.ok
      run User.a.info.path-qs.update.ok
      run User.a.password.min-lt.update.bad
      run User.a.password.max-gt.update.bad
      run User.a.password.weak-num.update.bad
      run User.a.password.weak-sym.update.bad
      run User.a.password.weak-ucase.update.bad
      run Session.signout.ok
      run Session.a.signin.password.a.bad
      run Session.a.signin.password.b.ok
    describe 'graph', ->
      run Node.list.is0
      run Node.a.create.ok
      run Node.a.read.ok
      run Node.a.name.max.update.ok
      run Node.a.name.max.read.ok
      run Node.a.name.max-gt.update.bad
      run Node.a.name.min.update.ok
      run Node.a.name.min-lt.update.bad
      run Node.a.name.space.multi.update.bad
      run Node.a.name.space.start.update.bad
      run Node.a.name.space.end.update.bad
      run Node.a.name.the.start.update.bad
      run Node.a.name.the.has.update.ok
      run Node.a.name.you.update.ok
      run Node.a.name.dcms.update.ok
      run Node.a.name.paren.open.update.ok
      run Node.a.name.update.ok
      run Node.a.name.dup.update.bad
      run Node.b.create.bad         # prior node missing evidence
      run Evidence.a.list.is0
      run Evidence.a0.create.ok
      run Evidence.a.list.is1
      run Evidence.a0.create.bad    # dup
      run Node.a.name.update.bad    # has evidence
      run Evidence.a.url.path.create.ok
      run Evidence.a.url.path.read.ok
      run Evidence.a.url.path-qs.create.ok
      run Evidence.a.url.no-http.create.bad
      run Evidence.a.url.no-path.create.bad
      run Evidence.a.url.no-domain.create.bad
      run Evidence.a1.create.ok
      run Evidence.a.list.is4
      run Evidence.a1.remove.ok
      run Evidence.a.url.path.remove.ok
      run Evidence.a.url.path-qs.remove.ok
      run Evidence.a.list.is1
      run Node.b.create.ok
      run Evidence.b.list.is0
      run Edge.aa.create.bad        # loop
      run Edge.ab.create.bad        # b missing evidence
      run Node.c.create.bad         # prior node missing evidence
      run Evidence.b0.create.ok
      run Evidence.b.list.is1
      run Node.b.create.bad         # dup
      run Node.c.create.ok; run Evidence.c0.create.ok
      run Node.d.create.ok; run Evidence.d0.create.ok
      run Node.e.create.ok; run Evidence.e0.create.ok
      run Node.f.create.bad         # count > 5
      run Node.list.is5
      run Node.c.remove.bad         # has evidence
      run Edge.list.is0
      run Edge.ab.create.ok
      run Edge.ab.create.bad        # dup
      run Edge.ab.to-ab.update.ok
      run Edge.ab.to-bc.update.bad  # ab immutable
      run Edge.ab.is.eq.update.ok
      run Edge.ab.is.eq.read.ok
      run Edge.ab.is.gt.update.bad
      run Edge.ab.how.max.update.ok
      run Edge.ab.how.max.read.ok
      run Edge.ab.how.max-gt.update.bad
      run Edge.ab.how.min.update.ok
      run Edge.ab.how.min-lt.update.bad
      run Edge.ab.how.amp.update.ok
      run Edge.ab.how.comma.update.ok
      run Edge.ab.how.slash.update.ok
      run Edge.ab.year.from.null.update.ok
      run Edge.ab.year.from.max.update.ok
      run Edge.ab.year.from.max-gt.update.bad
      run Edge.ab.year.from.min.update.ok
      run Edge.ab.year.from.min-lt.update.bad
      run Edge.ab.year.range.in.update.ok
      run Edge.ab.year.range.in.read.ok
      run Edge.ab.year.range.out.update.bad
      run Edge.ac.create.bad        # prior edge missing evidence
      run Evidence.ab0.create.ok
      run Edge.ba.create.bad        # reciprocal ab
      run Edge.ac.create.ok
      run Edge.list.is2
      run Edge.ac.to-ba.update.bad  # reciprocal ab
      run Edge.bc.create.bad        # prior edge missing evidence
      run Evidence.ac0.create.ok
      run Evidence.ac1.create.ok    # count > 5
      run Node.c.remove.bad         # has edge
      run Edge.ac.remove.bad        # has evidence
      run Evidence.ac0.remove.ok
      run Evidence.ac1.remove.ok
      run Edge.ac.remove.ok
      run Edge.list.is1
      run Node.a.remove.bad         # has edge
      run Node.b.remove.bad         # has edge
      run Evidence.c0.remove.ok
      run Node.c.remove.ok
      run Node.list.is4
    describe 'note', ->
      run Note.a.list.is0
      run Note.a.create.ok
      run Note.b.text.tqbf.create.ok
      run Note.a.list.is1
      run Note.a.text.min.create.bad # count > 1
      run Note.a.text.min.update.ok
      run Note.a.text.min-lt.update.bad
      run Note.a.text.max.update.ok
      run Note.a.text.max-gt.update.bad
      run Note.a.remove.ok
      run Note.a.list.is0
      run Note.b.list.is1
  describe 'user B', ->
    run Session.signout.ok
    run Session.b.signin.bad.login
    #run Session.b.signin.bad.password
    #run User.b.verify.ok
    run Session.b.signin.password.a.ok
    describe 'graph', ->
      run Node.a.name.update.bad
      run Node.a.remove.bad
      run Node.b.remove.bad
      run Evidence.a0.remove.bad
      run Node.c.create.ok
      run Evidence.c0.create.ok
      run Edge.bc.create.ok
      run Evidence.bc0.create.ok
      run Node.f.create.ok
    describe 'note', ->
      run Note.b.remove.bad
      run Note.b.create.ok
      run Note.b.list.is2
      run Note.b.text.min.create.bad # count > 1
    describe 'user', ->
      run User.a.info.path.update.bad
      run User.a.remove.bad
      run User.b.remove.ok
      run Session.signout.ok
      run Session.b.signin.password.a.bad
  describe 'admin', ->
    run Session.admin.signin.bad.login
    run Session.admin.signin.bad.password
    run Session.admin.signin.password.a.ok
    describe 'user', ->
      run User.a.password.c.update.ok
      run User.a.trust-level.six.update.ok
      run User.c.remove.ok
    describe 'graph', ->
      run Node.a.name.max.update.ok # dispite edge
      run Edge.ab.to-ba.update.ok   # dispite immutable
      run Evidence.bc0.remove.ok
      run Edge.bc.remove.ok
      run Evidence.c0.remove.ok
      run Node.c.remove.ok
      run Node.f.remove.ok
      run Node.list.is4
  describe 'signout', ->
    run Session.signout.ok
    run Node.a.create.bad       # signed out
    run Edge.ab.create.bad      # signed out
    run Edge.ab.remove.bad      # signed out

function kill-site cb then
  err <- CP.exec "pkill -f 'node boot.js test'"
  # err.code:
  # 0 One or more processes matched the criteria. 
  # 1 No processes matched. 
  # 2 Syntax error in the command line. 
  # 3 Fatal error: out of memory etc. 
  throw new Error "pkill returned #{err?code}" if err?code > 1
  cb err

function drop-db cb then
  DB.connect!
  err <- M.connection.db.executeDbCommand dropDatabase:1
  throw new Error "dropDatabase failed: #{err}" if err
  err <- M.disconnect
  throw new Error "disconnect failed: #{err}" if err
  cb!

function spawn-site opts then
  site = CP.spawn \node, <[ boot.js test ]>, opts
  site.unref! # prevent parent process from hanging around
  site

function run spec then test spec.info, spec.fn
