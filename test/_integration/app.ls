global.log = console.log

W        = require \wait.for
R        = require \./helper .run
B        = require \./app/_browser
Edge     = require \./app/edge
Evidence = require \./app/evidence
Map      = require \./app/map
Node     = require \./app/node
Note     = require \./app/note
OpenAuth = require \./app/openauth
Session  = require \./app/session
User     = require \./app/user

throw new Error "unexpected environment #env" unless \tester is env = process.env.NODE_ENV

function test spec then it spec.info, spec.fn

t = it
<- describe 'app'
@timeout 15000

before R ->
  B.init!

after R ->
  B.go \__coverage # https://github.com/gotwarlost/istanbul-middleware

t 'click About' R ->
  B.click \About
  B.wait-for \About \h3

t 'click Latest' R ->
  B.click \Latest
  B.wait-for 'Latest Updates' \legend

describe \admin ->
  describe 'signup users' ->
    test User.list.is0
    test User.admin.create.ok
    test User.list.is1
    test User.admin.create.bad
    test User.handle.min.create.bad
    test Session.admin.password.a.signin.ok
    test User.a.password.null.create.bad
    test User.a.create.ok
    test User.a.email.new.update.ok
    test User.a.create.bad
    test User.b.create.ok
    test User.list.is3
  describe 'node' ->
    test Node.list.is0
    test Node.a.create.ok
    test Node.a.name.max.update.ok
    test Node.a.name.max-gt.update.bad
    test Node.a.name.update.ok
    test Node.a.name.dup.update.bad
    test Node.b.create.bad # node a missing evidence
  describe 'map' ->
    test Map.a0.create.ok # default map
    test Session.signout.ok
#describe 'openauth signup' ->
  #test OpenAuth.github
  #test User.list.is4
describe \userA ->
  test Session.z.password.a.signin.bad
  test Session.a.password.z.signin.bad
  test Session.a.password.a.signin.ok
  describe 'maint' ->
    test User.a.password.b.update.ok
    test Session.signout.ok
    test Session.a.password.a.signin.bad
    test Session.a.password.b.signin.ok
  describe 'node' ->
    test Evidence.a.list.is0
    test Evidence.a0.create.ok # b can add evidence to a's node
    test Evidence.a0.create.bad
    test Evidence.a0.update.ok
    test Evidence.a1.create.ok
    test Evidence.a.list.is2
    test Evidence.a1.update.ok
    test Node.b.create.ok
    test Node.list.is2
    test Evidence.b0.create.ok
  describe 'map' ->
    test Map.a1.create.ok
  describe 'edge' ->
    test Edge.list.is0
    test Edge.ab.create.ok
    test Edge.list.is1
    test Edge.ab.create.bad # dup
    test Edge.ab.is.eq.update.ok
    test Edge.ab.when.DMY1-DMY2.update.ok
    test Evidence.ab0.create.ok
  describe 'note' ->
    test Note.a.list.is0
    test Note.a.create.ok
    test Note.a.text.jotld.update.ok
    test Note.a.list.is1
describe \userB ->
  test Session.signout.ok
  test Session.b.password.a.signin.ok
  describe 'note' ->
    test Note.a.create.ok
    test Note.a.text.max.update.ok
    test Note.a.list.is2
    test Note.a.remove.ok
    test Note.a.list.is1
  describe 'delete self' ->
    test User.b.remove.ok

#t 'map', R ->
#  B.refresh!
#  B.click \Graph
#  B.wait-for-visible sel:'.view>.graph'
#  B.assert.count 2, sel:'.graph g.node'
# TODO: why does B.assert.count think line is not displayed ?
# B.assert.count 1, sel:'.graph line.edge'

describe 'teardown' ->
  describe 'userA' ->
    test Session.a.password.b.signin.ok
    test Edge.ab.remove.bad # still has evidence
    test Evidence.ab0.remove.ok
    test Edge.ab.remove.ok
    test Note.a.remove.ok
    test Note.a.list.is0
    test Evidence.a0.remove.ok
    test Evidence.a1.remove.ok
    test Evidence.a.list.is0
    test Evidence.b0.remove.ok
    test Node.b.remove.bad # still on map
    test Map.a1.remove.ok
    test Node.b.remove.ok
  describe 'admin' ->
    test Session.signout.ok
    test Session.admin.password.a.signin.ok
    describe 'remove users' ->
      test User.a.remove.ok
      test User.list.is1
describe 'recreate users' -> # ensure no orphaned logins causing duplicate key error
  test User.a.create.ok
  test User.b.create.ok
  test User.list.is3
