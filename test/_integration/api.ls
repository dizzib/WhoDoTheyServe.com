global.log = console.log

Sh       = require \chai .should!
U        = require \util
W4       = require \wait.for .for
R        = require \./helper .run
Http     = require \./api/_http
Evidence = require \./api/evidence
Edge     = require \./api/edge
Hive     = require \./api/hive
Map      = require \./api/map
Node     = require \./api/node
Note     = require \./api/note
OpenAuth = require \./api/openauth
Session  = require \./api/session
Sys      = require \./api/sys
User     = require \./api/user

unless \tester is env = process.env.NODE_ENV
  throw new Error "unexpected environment #env"

function test spec then it spec.info, spec.fn

(...) <- describe 'api'
@timeout 10000

it '/sys access should increment hit count after a short while', R ->
  Http.assert W4 Http.get, \sys
  # this test completes at the end of this file

it '---admin'
test User.list.is0
test User.admin.create.ok
test User.admin.create.bad
test User.handle.min.create.bad
test Session.admin.password.a.signin.ok
test User.handle.min.create.ok
test User.handle.max.create.ok
test User.handle.num4.create.ok
test User.handle.num3.create.ok
test User.handle.num2.create.bad
test User.handle.num1.create.bad
test User.handle.min-lt.create.bad
test User.handle.max-gt.create.bad
test User.handle.has-space.create.bad
test User.handle.has-ucase.create.bad
test User.handle.has-hyphen.create.bad
test User.handle.min.remove.ok
test User.handle.max.remove.ok
test User.handle.num4.remove.ok
test User.handle.num3.remove.ok
test User.a.create.ok
test User.a.email.new.update.ok
test User.a.email.new.read.ok
test User.a.create.bad
test User.b.create.ok
test User.c.create.ok
test User.d.create.ok
test User.list.is5
test User.e.create.bad # daily signup max
test Hive.a.set.ok
test Session.a.password.a.signin.bad # signout required
test Session.signout.ok

it '---openauth'
test Session.null.read.ok
test OpenAuth.oa1.leg1.ok
test OpenAuth.oa1.leg2.ok
test User.oa1.read.ok
test Session.oa1.read.ok
test Session.signout.ok
test OpenAuth.oa2.leg1.ok # update name
test OpenAuth.oa2.leg2.ok
test Session.oa2.read.ok
test Session.signout.ok
test OpenAuth.fail.leg1.bad
test OpenAuth.fail.leg2.bad
test User.oa2.read.ok
test User.list.is6

it '---public'
test Hive.a.get.ok
test Hive.b.get.bad

it '---userA'
test Session.z.password.a.signin.bad
test Session.a.password.z.signin.bad
test Session.a.password.a.signin.ok
test Hive.a.set.bad # not admin
it 'maint'
test User.a.quota-daily.six.update.bad
test User.a.password.b.update.ok
test User.a.email.null.update.ok
test User.a.email.no-domain.update.bad
test User.a.email.no-dot.update.bad
test User.a.email.no-name.update.bad
test User.a.email.mailto.update.bad
test User.a.email.new.update.ok
test User.a.email.new.read.ok
test User.a.info.no-http.update.bad
test User.a.info.no-path.update.bad
test User.a.info.no-domain.update.bad
test User.a.info.path.update.ok
test User.a.info.path.read.ok
test User.a.info.path-qs.update.ok
test User.a.password.min-lt.update.bad
test User.a.password.max-gt.update.bad
test User.a.password.weak-num.update.bad
test User.a.password.weak-sym.update.bad
test User.a.password.weak-ucase.update.bad
test Session.signout.ok
test Session.a.password.a.signin.bad
test Session.a.password.b.signin.ok
it 'node'
test Node.list.is0
test Node.a.create.ok
test Node.a.read.ok
test Node.a.name.max.update.ok
test Node.a.name.max.read.ok
test Node.a.name.max-gt.update.bad
test Node.a.name.min.update.ok
test Node.a.name.dash.update.ok
test Node.a.name.min-lt.update.bad
test Node.a.name.space.multi.update.bad
test Node.a.name.space.start.update.bad
test Node.a.name.space.end.update.bad
test Node.a.name.the.start.update.bad
test Node.a.name.the.has.update.ok
test Node.a.name.you.update.ok
test Node.a.name.dcms.update.ok
test Node.a.name.paren.open.update.ok
test Node.a.name.update.ok
test Node.a.name.dup.update.bad
test Node.b.create.bad # prior node missing evidence
test Evidence.a.list.is0
test Evidence.a0.create.ok
test Evidence.a0.create.bad # dup
test Evidence.a.list.is1
test Evidence.a.url.path.create.ok
test Evidence.a.url.path.read.ok
test Evidence.a.url.path-qs.create.ok
test Evidence.a.url.no-http.create.bad
test Evidence.a.url.no-path.create.bad
test Evidence.a.url.no-domain.create.bad
test Evidence.a1.create.ok
test Evidence.a.list.is4
test Evidence.a1.remove.ok
test Evidence.a.url.path.remove.ok
test Evidence.a.url.path-qs.remove.ok
test Evidence.a.list.is1
test Node.a.remove.bad # has evidence
test Node.a.name.update.bad # has evidence
it 'note'
test Note.a.list.is0
test Note.a.create.ok
test Note.a.list.is1
test Note.a.text.min.create.bad # count > 1
test Note.a.text.min.update.ok
test Note.a.text.min-lt.update.bad
test Note.a.text.max.update.ok
test Note.a.text.max-gt.update.bad
it 'edge'
test Edge.aa.create.bad # loop
it 'map'
test Map.list.is0
test Map.a.create.ok
test Map.list.is1
it 'sys'
test Sys.mode.toggle.bad

it '---userB'
test Session.signout.ok
test Session.b.password.b.signin.bad
test Session.b.password.a.signin.ok
it 'node'
test Node.a.name.update.bad
test Node.a.remove.bad
test Evidence.a0.remove.bad
test Node.b.create.ok
test Evidence.b.list.is0
it 'note'
test Note.b.list.is0
test Note.b.create.ok
test Note.b.list.is1
test Note.b.text.min.create.bad # count > 1
test Note.b.remove.ok
test Note.b.list.is0
test Note.a.create.ok
test Note.a.list.is2
it 'edge'
test Evidence.b0.create.ok
test Evidence.b.list.is1
test Node.b.create.bad # dup
test Edge.list.is0
test Edge.ab.create.ok
test Edge.ab.create.bad # dup
test Edge.ab.to-ab.update.ok
test Edge.ab.is.eq.update.ok
test Edge.ab.is.eq.read.ok
test Edge.ab.is.gt.update.bad
test Edge.ab.how.max.update.ok
test Edge.ab.how.max.read.ok
test Edge.ab.how.max-gt.update.bad
test Edge.ab.how.min.update.ok
test Edge.ab.how.min-lt.update.bad
test Edge.ab.how.amp.update.ok
test Edge.ab.how.caps.update.ok
test Edge.ab.how.comma.update.ok
test Edge.ab.how.number.update.ok
test Edge.ab.how.slash.update.ok
test Edge.ab.year.from.null.update.ok
test Edge.ab.year.from.max.update.ok
test Edge.ab.year.from.max-gt.update.bad
test Edge.ab.year.from.min.update.ok
test Edge.ab.year.from.min-lt.update.bad
test Edge.ab.year.range.in.update.ok
test Edge.ab.year.range.in.read.ok
test Edge.ab.year.range.out.update.bad
test Edge.ba.create.bad # reciprocal
test Edge.list.is1
it 'node'
test Node.a.remove.bad # has edge
test Node.b.remove.bad # has edge
test Node.g.create.ok # node g to test map integrity
it 'users'
test User.a.info.path.update.bad
test User.a.remove.bad

it '---userC'
test Session.signout.ok
test Session.c.password.a.signin.ok
it 'graph'
test Node.c.create.ok
test Edge.ab.create.bad # already exists
test Edge.ba.create.bad # already exists
test Edge.ca.create.bad # a_node missing evidence
test Edge.ac.create.bad # b_node missing evidence
test Evidence.c0.create.ok
test Edge.ac.create.ok
test Evidence.ac0.create.ok
test Edge.bc.create.ok
test Edge.list.is3
test Edge.ac.to-bc.update.bad
test Node.d.create.ok
test Evidence.d0.create.ok
test Edge.ac.to-ad.update.bad
test Evidence.bc0.create.ok
test Node.c.remove.bad # has edge
test Edge.ac.remove.bad # has evidence
test Evidence.ac0.remove.ok
test Edge.ac.remove.ok
test Edge.list.is2
it 'map'
test Map.c.create.ok
test Map.list.is2
test Map.c.read.ok
test Map.c.entities.edges.is2
test Edge.ac.create.ok
test Map.c.read.ok
test Map.c.entities.edges.is2 # latest edge ac should be excluded
test Edge.ac.remove.ok
test Evidence.bc0.remove.ok
test Edge.bc.remove.bad # on map c
it 'node quota'
test Node.e.create.ok
test Evidence.e0.create.ok
test Node.f.create.bad # > quota

it '---userB teardown'
test Session.signout.ok
test Session.b.password.a.signin.ok
test Node.g.name.update.bad # on userC's map
test Node.g.remove.bad # on userC's map
test User.b.remove.ok # remove self
test Session.signout.bad # should already be signed out
test Session.b.password.a.signin.bad

it '---admin'
test Session.admin.password.z.signin.bad
test Session.admin.password.a.signin.ok
test Hive.b.set.ok
it 'graph'
test Node.a.name.max.update.ok # despite edge
test Edge.ab.to-ba.update.ok # despite immutable
test Map.c.remove.ok
test Edge.bc.remove.ok
test Evidence.c0.remove.ok
test Node.c.remove.ok
it 'user'
test User.a.password.c.update.ok
test User.a.quota-daily.six.update.ok

it '---sys.mode toggle maintenance/normal'
test Sys.mode.normal.read.ok
test Sys.mode.toggle.ok
test Sys.mode.maintenance.read.ok
test Session.signout.ok
test Session.a.password.c.signin.bad
test Session.admin.password.a.signin.ok
test Sys.mode.toggle.ok
test Sys.mode.normal.read.ok
test Session.signout.ok
test Session.a.password.c.signin.ok
test Session.signout.ok

it '---public'
test Node.a.create.bad
test Edge.ab.create.bad
test Edge.ab.remove.bad
test Hive.a.get.ok
test Hive.b.get.ok

it '/sys access should have incremented hit count after a short while', R ->
  Http.assert res = W4 Http.get, "hive/n-hits-#{new Date!getFullYear!}"
  n-hits = JSON.parse res.object.value
  n-hits[*-1].should.equal 1
