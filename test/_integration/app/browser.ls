Should = require \chai .should!
_      = require \underscore
Z      = require \zombie
H      = require \./helper
S      = require \../../../server

throw new Error "unexpected environment #{env}" unless S.settings.env is \test

z = new Z do
  site        : \http://localhost:4001
  #debug       : true
  waitDuration: 500ms

module.exports = _.extend z,
  assert: (is-ok) -> if is-ok then @ok! else @err!
  ok    : -> @is-ok! .should.equal true
  err   : -> @is-ok! .should.equal false
  is-ok : -> not @is-err!
  is-err: ->
    errors = @evaluate "$('.alert-error:visible')"
    H.log errors.html! if is-err = errors.length > 0
    is-err
  link: (text, done) ->
    H.log sel = "$('a:contains(\'#{text}\')').click()"
    @evaluate sel
    err <- @wait
    done err
  go : (path, done) ->
    #@location = path
    #err <- @wait
    err <- @visit path
    done err
  reset : (done) ->
    @visit '#/about'
      .then ~>
        # TODO: submit zombie focus bug to github
        # Issue occurs in view engine edit.render focus 1st textbox
        # Here's the workaround
        @evaluate "$.prototype.focus = function() { return; }"
      .then ~>
        # patch jquery show/hide to tag hidden elements
        # https://github.com/assaf/zombie/issues/429
        #log J
        done!
      .fail -> done it
