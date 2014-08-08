Chai = require \chai .should!
H    = require \../spec/helper
Http = require \./_http

h = H \sys, void, read, update, void, void

module.exports =
  mode:
    maintenance: h.get-spec '', mode:\maintenance
    normal     : h.get-spec '', mode:\normal

function update key, is-ok, fields
  Http.assert (res = Http.put \sys, fields), is-ok

function read key, is-ok, fields
  Http.assert (res = Http.get \sys), is-ok
  sys = res.object
  sys.mode.should.equal fields.mode
