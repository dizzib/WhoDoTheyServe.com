_ = require \lodash
H = require \./helper

module.exports.get-spec = (signin, read, signout) ->
  h = H \session, signin, read, void, signout

  function get-spec handle, fields
    _.extend do
      h.get-spec handle, fields
      password:
        a: h.get-spec handle, password:\Pass1!
        b: h.get-spec handle, password:\Pass2!
        c: h.get-spec handle, password:\Pass3!
        z: h.get-spec handle, password:\zzzz

  _.extend do
    h.get-spec! # for signout
    admin: get-spec \admin
    a    : get-spec \usera
    b    : get-spec \userb
    c    : get-spec \userc
    d    : get-spec \userd
    z    : get-spec \userz
    oa1  : get-spec \openauth1, name:\oa1
    oa2  : get-spec \openauth2, name:\oa2
    null : get-spec \null
