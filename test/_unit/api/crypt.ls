Chai  = require \chai
Crypt = require \../../../api/crypt

should = Chai.should!
test   = it

const TEXT = 'The quick brown fox !@#$%^ .com'

describe.skip 'crypt' ->
  test 'encrypt then decrypt', (done) ->
    enc = Crypt.encrypt TEXT
    dec = Crypt.decrypt enc
    dec.should.equal TEXT
    dec.should.not.equal enc
    done!

  test 'decrypt clear', (done) ->
    dec = Crypt.decrypt TEXT
    dec.should.equal TEXT
    done!
