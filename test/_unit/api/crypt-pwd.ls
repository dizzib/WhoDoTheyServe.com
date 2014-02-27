Should   = require \chai .should!
CryptPwd = require "#{process.cwd!}/site/api/crypt-pwd"

(...) <- describe 'crypt-pwd'

it 'hash clear should hash password', (done) ->
  u = password: \foo123
  err <- CryptPwd.hash u
  CryptPwd.is-hashed(u.password).should.be.true
  Should.not.exist err
  done!

it 'hash hash should error', (done) ->
  u = password: \x * 60
  err <- CryptPwd.hash u
  err.should.exist
  done!

it 'check should pass if password is correct', (done) ->
  u = password: \foo123
  <- CryptPwd.hash u
  err, is-match <- CryptPwd.check \foo123, u.password
  Should.not.exist err
  is-match.should.be.true
  done!

it 'check should fail if password is incorrect', (done) ->
  u = password: \foo123
  <- CryptPwd.hash u
  err, is-match <- CryptPwd.check \bar456, u.password
  Should.not.exist err
  is-match.should.be.false
  done!
