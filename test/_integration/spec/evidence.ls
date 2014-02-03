_ = require \underscore
H = require \./helper

exports.get-spec = (...args) ->
  h = H \evidence, ...args

  function add-evidences spec, name then
    spec["#{name}0"] = h.get-spec "#{name}:0", url:"http://#{name}-0.com"
    spec["#{name}1"] = h.get-spec "#{name}:1", url:"http://#{name}-1.com"

  spec =
    a:
      list:
        is0: h.get-spec-list 0, \a
        is1: h.get-spec-list 1, \a
        is2: h.get-spec-list 2, \a
        is3: h.get-spec-list 3, \a
        is4: h.get-spec-list 4, \a
      url:
        no-http   : h.get-spec \a:x, url:\foo
        no-path   : h.get-spec \a:x, url:\http://
        no-domain : h.get-spec \a:x, url:\http://foo
        path      : h.get-spec \a:2, url:\http://foo.com
        path-qs   : h.get-spec \a:3, url:\http://foo.com?bar=boo
    b:
      list:
        is0: h.get-spec-list 0, \b
        is1: h.get-spec-list 1, \b

  add-evidences spec, \a
  add-evidences spec, \ab
  add-evidences spec, \ac
  add-evidences spec, \b
  add-evidences spec, \bc
  add-evidences spec, \c
  add-evidences spec, \d
  add-evidences spec, \e

  spec
