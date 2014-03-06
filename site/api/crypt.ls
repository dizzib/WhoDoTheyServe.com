Crypto = require \crypto

const ALGO = \aes-256-cbc

secret = process.env.WDTS_CRYPTO_SECRET or \secret

module.exports =
  encrypt: (data) ->
    c    = Crypto.createCipher ALGO, secret
    res  = c.update data, \utf8, \hex
    res += c.final \hex
  decrypt: (data) ->
    try
      d    = Crypto.createDecipher ALGO, secret
      res  = d.update data, \hex, \utf8
      res += d.final \utf8
    catch
      return data
    res
