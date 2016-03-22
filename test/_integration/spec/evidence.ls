H = require \./helper

exports.get-spec = (...args) ->
  h = H \evidence ...args

  function add-evidences spec, name
    spec["#{name}0"] = h.get-spec "#{name}:0" url:"http://#{name}-0.com"
    spec["#{name}1"] = h.get-spec "#{name}:1" url:"http://#{name}-1.com" bare_href:true

  spec =
    a:
      list: {["is#n" h.get-spec-list n, \a] for n from 0 to 9}
      url:
        no-http  : h.get-spec \a:x url:\foo
        no-path  : h.get-spec \a:x url:\http://
        no-domain: h.get-spec \a:x url:\http://foo
        path     : h.get-spec \a:2 url:\http://foo.com
        path-qs  : h.get-spec \a:3 url:\http://foo.com?bar=boo
      timestamp:
        bare-href: h.get-spec \a:x url:\http://bar.com timestamp:\2009 bare_href:true
        yy       : h.get-spec \a:x url:\http://bas.com timestamp:\20
        yyyy     : h.get-spec \a:4 url:\http://bap.com timestamp:\2009
        yyyymm   : h.get-spec \a:5 url:\http://baz.com timestamp:\200905
        yyyymmdd : h.get-spec \a:6 url:\http://bop.com timestamp:\20090524
        yyyymmddh: h.get-spec \a:6 url:\http://boq.com timestamp:\200905248
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
