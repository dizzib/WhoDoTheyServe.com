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

unless \tester is env = process.env.NODE_ENV
  throw new Error "unexpected environment #env"

function test spec then it spec.info, spec.fn

(...) <- describe 'app'
@timeout 15000

before R ->
  B.init!

after R ->
  B.go \__coverage # https://github.com/gotwarlost/istanbul-middleware

it 'click About', R ->
  B.click \About
  B.wait-for \About, \h3

it 'click Latest', R ->
  B.click \Latest
  B.wait-for 'Latest Updates', \legend

it '---admin'
it 'signup users'
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
it 'node'
test Node.list.is0
test Node.a.create.ok
test Node.a.name.max.update.ok
test Node.a.name.max-gt.update.bad
test Node.a.name.update.ok
test Node.a.name.dup.update.bad
test Node.b.create.bad # node a missing evidence
it 'map'
test Map.a.create.ok # default map
test Session.signout.ok
#it '---openauth signup'
#test OpenAuth.github
#test User.list.is4
it '---userA'
test Session.z.password.a.signin.bad
test Session.a.password.z.signin.bad
test Session.a.password.a.signin.ok
it 'maint'
test User.a.password.b.update.ok
test Session.signout.ok
test Session.a.password.a.signin.bad
test Session.a.password.b.signin.ok
it 'node'
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
it 'map'
test Map.b.create.ok
it 'edge'
test Edge.list.is0
test Edge.ab.create.ok
test Edge.list.is1
test Edge.ab.create.bad # dup
test Edge.ab.is.eq.update.ok
test Edge.ab.when.DMY1-DMY2.update.ok
test Evidence.ab0.create.ok
it 'note'
test Note.a.list.is0
test Note.a.create.ok
test Note.a.text.jotld.update.ok
test Note.a.list.is1
it '---userB'
test Session.signout.ok
test Session.b.password.a.signin.ok
it 'note'
test Note.a.create.ok
test Note.a.text.max.update.ok
test Note.a.list.is2
test Note.a.remove.ok
test Note.a.list.is1
it 'delete self'
test User.b.remove.ok

#it 'map', R ->
#  B.refresh!
#  B.click \Graph
#  B.wait-for-visible sel:'.view>.graph'
#  B.assert.count 2, sel:'.graph g.node'
# TODO: why does B.assert.count think line is not displayed ?
# B.assert.count 1, sel:'.graph line.edge'

## teardown
it '---userA teardown'
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
test Map.b.remove.ok
test Node.b.remove.ok
it '---admin teardown'
test Session.signout.ok
test Session.admin.password.a.signin.ok
it 'remove users'
test User.a.remove.ok
test User.list.is1
it 'recreate users' # ensure no orphaned logins causing duplicate key error
test User.a.create.ok
test User.b.create.ok
test User.list.is3
