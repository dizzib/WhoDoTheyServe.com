Chai = require \chai .should!
H    = require \../helper
Http = require \./_http
Sh   = require \../spec/helper

h = Sh \sys, void, read, void, void, void

module.exports =
  mode:
    maintenance: h.get-spec '', mode:\maintenance
    normal     : h.get-spec '', mode:\normal
    toggle:
      ok : get-spec-toggle-mode true
      bad: get-spec-toggle-mode false

function get-spec-toggle-mode is-ok
  info: "sys mode toggle #{if is-ok then '' else 'bad '}"
  fn  : H.run -> Http.assert (res = Http.get \sys/mode/toggle), is-ok

function read key, is-ok, fields
  Http.assert (res = Http.get \sys), is-ok
  sys = res.object
  sys.mode.should.equal fields.mode
