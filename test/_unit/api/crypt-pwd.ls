Chai     = require \chai
CryptPwd = require \../../../api/crypt-pwd

should = Chai.should!
test = it

describe.skip 'crypt-pwd' ->
  test 'hash clear should hash password', (done) ->
    u = password: \foo123
    err <- CryptPwd.hash u
    CryptPwd.is-hashed(u.password).should.be.true
    should.not.exist err
    done!

  test 'hash hash should error', (done) ->
    u = password: \x * 60
    err <- CryptPwd.hash u
    err.should.exist
    done!

  test 'check should pass if password is correct', (done) ->
    u = password: \foo123
    <- CryptPwd.hash u
    err, is-match <- CryptPwd.check \foo123, u.password
    should.not.exist err
    is-match.should.be.true
    done!

  test 'check should fail if password is incorrect', (done) ->
    u = password: \foo123
    <- CryptPwd.hash u
    err, is-match <- CryptPwd.check \bar456, u.password
    should.not.exist err
    is-match.should.be.false
    done!
