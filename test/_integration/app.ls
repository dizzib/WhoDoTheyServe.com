B = require \./app/browser

test = it
l = console.log

describe.skip 'app', ->
  @timeout 10000

  before (done) -> B.reset done

  test 'nodes', (done) ->
    <- B.go \#/nodes
    #l B.html \div.nodes
    done!

  test 'edges', (done) ->
    <- B.go \#/edges
    #l B.html \div.edges
    done!

  test 'disclaimer', (done) ->
    #l B.evaluate "$(a:contains(\'Disclaimer\')).click()"
    #l B.evaluate "$('a.dis').click()"
    #<- B.wait
    #<- B.link \Disclaimer
    #<- B.clickLink \About
    #<- B.clickLink \a.dis
    #l B.html \.doc-disclaim
    done!

  test 'signin', (done) ->
    <- B.go \#/user-signin
    l B.is-ok!
    #l B.html \div.user-signin
    <- B.fill \Login, \admin
    <- B.fill \Password, \Pass1!
    <- B.pressButton \Create
    #l B.html \div.alert
    l B.is-ok!
    #l B.html \div.session-info
    #<- B.go \#/nodes
    #l B.html \div.nodes
    done!
