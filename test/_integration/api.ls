global.log = console.log

Sh       = require \chai .should!
U        = require \util
W4       = require \wait.for .for
R        = require \./helper .run
Http     = require \./api/_http
Evidence = require \./api/evidence
Edge     = require \./api/edge
Hive     = require \./api/hive
Latest   = require \./api/latest
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

t = it
<- describe 'api'
@timeout 10000

t '/sys access should increment hit count after a short while' R ->
  Http.assert W4 Http.get, \sys
  # this test completes at the end of this file

describe 'admin' ->
  test User.list.is0
  test User.admin.create.ok
  test User.admin.create.bad
  test User.handle.min.create.bad
  test Session.admin.password.z.signin.bad
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
  test User.a.email.new.read.ok
  test User.a.quota-daily.six.update.ok
  test User.a.password.b.update.ok
  test User.a.create.bad
  test User.b.create.ok
  test User.b.read.ok # admin can see any user's email
  test User.c.create.ok
  test User.d.create.ok
  test User.list.is5
  test User.e.create.bad # daily signup max
  test Hive.a.set.ok
  test Session.a.password.b.signin.bad # signout required
describe 'public' ->
  test Session.signout.ok
  test Hive.a.get.ok
  test Hive.b.get.bad
  test User.a.read.bad # cannot read email
  test User.b.read.bad # cannot read email
describe 'openauth' ->
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
describe 'more admin' ->
  test Session.admin.password.a.signin.ok
  test Hive.b.set.ok
  describe 'sys.mode toggle maintenance/normal' ->
    test Sys.mode.normal.read.ok
    test Sys.mode.toggle.ok
    test Sys.mode.maintenance.read.ok
    test Session.signout.ok
    test Session.a.password.b.signin.bad # maint mode
    test Session.admin.password.a.signin.ok
    test Sys.mode.toggle.ok
    test Sys.mode.normal.read.ok
describe 'userA' ->
  test Session.signout.ok
  test Session.z.password.a.signin.bad
  test Session.a.password.a.signin.bad
  test Session.a.password.b.signin.ok
  test Hive.a.set.bad # not admin
  describe 'maint' ->
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
    test User.a.quota-daily.four.update.bad
    test User.a.password.min-lt.update.bad
    test User.a.password.max-gt.update.bad
    test User.a.password.weak-num.update.bad
    test User.a.password.weak-sym.update.bad
    test User.a.password.weak-ucase.update.bad
    test User.a.password.c.update.ok
    test Session.signout.ok
    test Session.a.password.b.signin.bad
    test Session.a.password.c.signin.ok
    test Latest.is0.void
  describe 'node a' ->
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
    test Node.a.name.ucase.update.ok
    test Node.a.tags.lcase1.update.ok
    test Node.a.tags.lcase2.update.ok
    test Node.a.tags.ucase.update.bad
    test Node.a.tags.min-lt.update.bad
    test Node.a.tags.max-gt.update.bad
    test Node.a.when.deceased.update.ok
    test Node.a.when.deceased.read.ok
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
    test Evidence.a.timestamp.yyyy.create.ok
    test Evidence.a.timestamp.yyyymm.create.ok
    test Evidence.a.timestamp.yyyymmdd.create.ok
    test Evidence.a.timestamp.yyyymmdd.read.ok
    test Evidence.a.timestamp.yy.create.bad
    test Evidence.a.timestamp.yyyymmddh.create.bad
    test Evidence.a.timestamp.bare-href.create.bad
    test Evidence.a1.create.ok
    test Evidence.a1.read.ok
    test Evidence.a.list.is7
    test Evidence.a1.remove.ok
    test Evidence.a.url.path.remove.ok
    test Evidence.a.url.path-qs.remove.ok
    test Evidence.a.timestamp.yyyy.remove.ok
    test Evidence.a.timestamp.yyyymm.remove.ok
    test Evidence.a.timestamp.yyyymmdd.remove.ok
    test Evidence.a.list.is1
    test Node.a.remove.bad # has evidence
    test Node.a.name.update.bad # has evidence
    test Latest.is1.node
  describe 'note a' ->
    test Note.a.list.is0
    test Note.a.create.ok
    test Note.a.list.is1
    test Note.a.text.min.create.bad # count > 1
    test Note.a.text.min.update.ok
    test Note.a.text.min-lt.update.bad
    test Note.a.text.max.update.ok
    test Note.a.text.max-gt.update.bad
    test Latest.is2.note
  describe 'node b' ->
    test Node.b.create.ok
    test Node.b.dup.update.bad
    test Evidence.b.list.is0
    test Evidence.b0.create.ok
    test Evidence.b.list.is1
    test Latest.is3.node
  describe 'edge' ->
    test Edge.aa.create.bad # loop
  describe 'map' ->
    test Map.list.is0
    test Map.a0.create.ok
    test Map.list.is1
    test Map.a1.create.ok
    test Map.list.is2
    test Map.ax.create.ok
    test Map.list.is3
  describe 'sys' ->
    test Sys.mode.toggle.bad
describe 'public' ->
  test Session.signout.ok
  test Map.list.is2
  test Latest.is5.map
describe 'userB' ->
  test Session.b.password.b.signin.bad
  test Session.b.password.a.signin.ok
  describe 'node a' ->
    test Node.a.name.update.bad
    test Node.a.remove.bad
    test Evidence.a0.remove.bad
  describe 'note b' ->
    test Note.b.list.is0
    test Note.b.create.ok
    test Note.b.list.is1
    test Note.b.text.min.create.bad # count > 1
    test Note.b.remove.ok
    test Note.b.list.is0
    test Note.a.create.ok
    test Note.a.list.is2
  describe 'edge ab' ->
    test Node.b.create.bad # dup
    test Edge.list.is0
    test Edge.ab.create.ok
    test Edge.ab.create.bad # dup
    test Edge.ab.to-aa.update.bad
    test Edge.ab.to-ab.update.ok
    test Edge.ab.is.eq.update.ok
    test Edge.ab.is.eq.read.ok
    test Edge.ab.is.gt.update.bad
    test Edge.ab.how.max.update.ok
    test Edge.ab.how.max.read.ok
    test Edge.ab.how.max-gt.update.bad
    test Edge.ab.how.min.update.ok
    test Edge.ab.how.min-lt.update.bad
    test Edge.ab.how.number.update.ok
    test Edge.ab.how.symbol.update.ok
    test Edge.ab.when.null.update.ok
    test Edge.ab.when.from.y.update.ok
    test Edge.ab.when.from.my.update.ok
    test Edge.ab.when.from.dmy.update.ok
    test Edge.ab.when.from.bad.update.bad
    test Edge.ab.when.to.y.update.ok
    test Edge.ab.when.to.my.update.ok
    test Edge.ab.when.to.dmy.update.ok
    test Edge.ab.when.to.bad.update.bad
    test Edge.ab.when.DMY1-DMY2.update.ok
    test Edge.ab.when.DMY2-DMY1.update.bad
    test Evidence.ab0.create.ok
    test Edge.list.is1
    test Latest.is7.edge
  describe 'edge ab chronological' ->
    test Edge.ba.create.bad # reciprocal
    test Edge.ab2.DMY2-DMY4.create.bad
    test Edge.ab2.DMY3-DMY4.create.ok
  describe 'map' ->
    test Map.a0.remove.bad
    test Map.a1.remove.bad
    test Map.a1.read.ok
    test Map.a1.entities.edges.is0 # b's latest edge ab should be excluded from a's map b
    test Map.ax.read.bad
  describe 'node' ->
    test Node.a.remove.bad # has edge
    test Node.b.remove.bad # has edge
    test Node.g.create.ok # node g to test map integrity
describe 'userC' ->
  test Session.signout.ok
  test Session.c.password.a.signin.ok
  describe 'graph' ->
    test Node.c.create.ok
    test Edge.ab.create.bad       # overlapping when
    test Edge.ba.create.bad       # overlapping when
    test Edge.ba.DMY4_.create.bad # overlapping when
    test Edge.ba.DMY5_.create.ok
    test Evidence.ba0.create.ok
    test Edge.ca.create.bad # a_node missing evidence
    test Edge.ac.create.bad # b_node missing evidence
    test Evidence.c0.create.ok
    test Edge.ac.create.ok
    test Evidence.ac0.create.ok
    test Edge.bc.create.ok
    test Edge.list.is5
    test Edge.ac.to-bc.update.bad
    test Node.d.create.ok
    test Evidence.d0.create.ok
    test Edge.ac.to-ad.update.bad
    test Evidence.bc0.create.ok
    test Node.c.remove.bad # has edge
    test Edge.ac.remove.bad # has evidence
    test Evidence.ac0.remove.ok
    test Edge.ac.remove.ok
    test Edge.list.is4
  describe 'map' ->
    test Map.c0.create.ok
    test Map.list.is3
    test Map.c0.read.ok
    test Map.c0.entities.nodes.is5
    test Map.c0.entities.edges.is4
    test Edge.ac.create.ok
    test Map.c0.read.ok
    test Map.c0.entities.edges.is5 # c's latest edge ac should be included on c's map
    test Map.c0.entities.evidences.is7
    test Map.c0.entities.notes.is2
    test Edge.ac.remove.ok
    test Evidence.bc0.remove.ok
    test Edge.bc.remove.bad # on map c
    test Map.cx.create.ok
    test Map.cx.read.ok
    test Map.list.is4
  describe 'node quota' ->
    test Node.e.create.ok
    test Evidence.e0.create.ok
    test Node.f.create.bad # > quota
  describe 'users' ->
    test User.a.info.path.update.bad
    test User.a.remove.bad
    test User.a.read.bad # cannot read email
    test User.b.read.bad # cannot read email
    test User.c.read.ok  # can only read own email
describe 'userD' -> # daily_quota = 0
  test Session.signout.ok
  test Session.d.password.a.signin.ok
  test Node.f.create.bad
  test Edge.ac.create.bad
describe 'public' ->
  test Session.signout.ok
  test Latest.read.ok
describe 'teardown' ->
  describe 'userB' ->
    test Session.b.password.a.signin.ok
    test Node.g.name.update.bad # on userC's map
    test Node.g.remove.bad # on userC's map
    test User.b.remove.ok # remove self
    test Session.signout.bad # should already be signed out
    test Session.b.password.a.signin.bad
  describe 'map' ->
    test Session.admin.password.a.signin.ok
    test Node.a.name.max.update.ok # despite edge
    test Edge.ab.to-ba.update.ok # despite immutable
    test Map.c0.remove.ok
    test Map.cx.read.ok
    test Edge.bc.remove.ok
    test Evidence.c0.remove.ok
    test Node.c.remove.ok
describe 'public' ->
  test Session.signout.ok
  test Node.a.create.bad
  test Edge.ab.create.bad
  test Edge.ab.remove.bad
  test Hive.a.get.ok
  test Hive.b.get.ok
  test Map.a0.remove.bad
  test Map.a1.remove.bad
  test Map.ax.remove.bad
  test Map.a0.read.ok
  test Map.ax.read.bad
  test Map.list.is2

describe 'sys' ->
  t '/sys access should have incremented hit count after a short while' R ->
    Http.assert res = W4 Http.get, "hive/n-hits-#{new Date!getFullYear!}"
    n-hits = JSON.parse res.object.value
    n-hits[*-1].should.equal 1
