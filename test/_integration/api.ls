global.log = console.log

Sh       = require \chai .should!
U        = require \util
W4       = require \wait.for .for
R        = require \./helper .run
Http     = require \./api/_http
Evidence = require \./api/evidence
Edge     = require \./api/edge
Hive     = require \./api/hive
Node     = require \./api/node
Note     = require \./api/note
Session  = require \./api/session
User     = require \./api/user

unless \tester is env = process.env.NODE_ENV
  throw new Error "unexpected environment #env"

function test spec then it spec.info, spec.fn

(...) <- describe 'api'
@timeout 10000

it '/sys access should increment hit count after a short while', R ->
  Http.assert W4 Http.get, \sys
  # this test completes at the end of this file

it 'signup'
test User.list.is0
test User.admin.create.ok
test User.admin.create.bad
test User.handle.min.create.bad
test Session.admin.signin.password.a.ok
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
#test Session.admin.signin.password.a.bad
#test User.admin.token.fake.verify.bad
#test User.admin.verify.ok
#test User.admin.verify.bad
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
test Session.a.signin.password.a.bad # signout required
test Session.signout.ok
it '---public'
test Hive.a.get.ok
test Hive.b.get.bad
it '---userA'
test Session.a.signin.bad.handle
test Session.a.signin.bad.password
#test Session.a.signin.password.a.bad
#test User.a.verify.ok
test Session.a.signin.password.a.ok
test Hive.a.set.bad # not admin
it 'maint'
test User.a.quota-daily.six.update.bad
test User.a.password.b.update.ok
test User.a.email.null.update.bad
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
test Session.a.signin.password.a.bad
test Session.a.signin.password.b.ok
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
test Evidence.a.list.is1
test Evidence.a0.create.bad # dup
test Node.a.name.update.bad # has evidence
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
test Node.b.create.ok
test Evidence.b.list.is0
it 'edge'
test Edge.aa.create.bad # loop
test Edge.ab.create.bad # b missing evidence
test Node.c.create.bad # prior node missing evidence
test Evidence.b0.create.ok
test Evidence.b.list.is1
test Node.b.create.bad # dup
test Node.c.create.ok
test Evidence.c0.create.ok
test Node.d.create.ok
test Evidence.d0.create.ok
test Node.e.create.ok
test Evidence.e0.create.ok
test Node.f.create.bad # count > 5
test Node.list.is5
test Node.c.remove.bad # has evidence
test Edge.list.is0
test Edge.ab.create.ok
test Edge.ab.create.bad # dup
test Edge.ab.to-ab.update.ok
test Edge.ab.to-bc.update.bad # ab immutable
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
test Edge.ac.create.bad # prior edge missing evidence
test Evidence.ab0.create.ok
test Edge.ba.create.bad # reciprocal ab
test Edge.ac.create.ok
test Edge.list.is2
test Edge.ac.to-ba.update.bad # reciprocal ab
test Edge.bc.create.bad # prior edge missing evidence
test Evidence.ac0.create.ok
test Evidence.ac1.create.ok # count > 5
test Node.c.remove.bad # has edge
test Edge.ac.remove.bad # has evidence
test Evidence.ac0.remove.ok
test Evidence.ac1.remove.ok
test Edge.ac.remove.ok
test Edge.list.is1
test Node.a.remove.bad # has edge
test Node.b.remove.bad # has edge
test Evidence.c0.remove.ok
test Node.c.remove.ok
test Node.list.is4
it 'note'
test Note.a.list.is0
test Note.a.create.ok
test Note.b.text.tqbf.create.ok
test Note.a.list.is1
test Note.a.text.min.create.bad # count > 1
test Note.a.text.min.update.ok
test Note.a.text.min-lt.update.bad
test Note.a.text.max.update.ok
test Note.a.text.max-gt.update.bad
test Note.a.remove.ok
test Note.a.list.is0
test Note.b.list.is1
test Session.signout.ok
it '---userB'
test Session.b.signin.bad.handle
#test Session.b.signin.bad.password
#test User.b.verify.ok
test Session.b.signin.password.a.ok
it 'graph'
test Node.a.name.update.bad
test Node.a.remove.bad
test Node.b.remove.bad
test Evidence.a0.remove.bad
test Node.c.create.ok
test Evidence.c0.create.ok
test Edge.bc.create.ok
test Evidence.bc0.create.ok
test Node.f.create.ok
it 'note'
test Note.b.remove.bad
test Note.b.create.ok
test Note.b.list.is2
test Note.b.text.min.create.bad # count > 1
it 'userA'
test User.a.info.path.update.bad
test User.a.remove.bad
test User.b.remove.ok
test Session.signout.ok
test Session.b.signin.password.a.bad
it '---admin'
test Session.admin.signin.bad.handle
test Session.admin.signin.bad.password
test Session.admin.signin.password.a.ok
test Hive.b.set.ok
it 'user'
test User.a.password.c.update.ok
test User.a.quota-daily.six.update.ok
test User.c.remove.ok
it 'graph'
test Node.a.name.max.update.ok # dispite edge
test Edge.ab.to-ba.update.ok # dispite immutable
test Evidence.bc0.remove.ok
test Edge.bc.remove.ok
test Evidence.c0.remove.ok
test Node.c.remove.ok
test Node.f.remove.ok
test Node.list.is4
test Session.signout.ok
it '---public'
test Node.a.create.bad # signed out
test Edge.ab.create.bad # signed out
test Edge.ab.remove.bad # signed out
test Hive.a.get.ok
test Hive.b.get.ok

it '/sys access should have incremented hit count after a short while', R ->
  Http.assert res = W4 Http.get, "hive/n-hits-#{new Date!getFullYear!}"
  n-hits = JSON.parse res.object.value
  n-hits[*-1].should.equal 1
