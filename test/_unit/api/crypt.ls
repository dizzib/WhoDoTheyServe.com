Chai  = require \chai
Crypt = require "#{process.cwd!}/site/api/crypt"

const TEXT = 'The quick brown fox !@#$%^ .com'

(...) <- describe 'crypt'

it 'encrypt then decrypt', ->
  enc = Crypt.encrypt TEXT
  dec = Crypt.decrypt enc
  dec.should.equal TEXT
  dec.should.not.equal enc

it 'decrypt clear', ->
  dec = Crypt.decrypt TEXT
  dec.should.equal TEXT
