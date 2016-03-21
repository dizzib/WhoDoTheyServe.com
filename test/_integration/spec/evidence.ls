H = require \./helper

exports.get-spec = (...args) ->
  h = H \evidence ...args

  function add-evidences spec, name
    spec["#{name}0"] = h.get-spec "#{name}:0" url:"http://#{name}-0.com"
    spec["#{name}1"] = h.get-spec "#{name}:1" url:"http://#{name}-1.com" bare_href:true

  spec =
    a:
      list: {["is#n" h.get-spec-list n, \a] for n from 0 to 4}
      url:
        no-http   : h.get-spec \a:x url:\foo
        no-path   : h.get-spec \a:x url:\http://
        no-domain : h.get-spec \a:x url:\http://foo
        path      : h.get-spec \a:2 url:\http://foo.com
        path-qs   : h.get-spec \a:3 url:\http://foo.com?bar=boo
    b:
      list: {["is#n" h.get-spec-list n, \b] for n from 0 to 1}

  add-evidences spec, \a
  add-evidences spec, \ab
  add-evidences spec, \ac
  add-evidences spec, \b
  add-evidences spec, \ba
  add-evidences spec, \bc
  add-evidences spec, \c
  add-evidences spec, \d
  add-evidences spec, \e

  spec
