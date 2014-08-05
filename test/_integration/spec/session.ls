_ = require \lodash
H = require \../helper
S = require \../state

exports.get-spec = (create, remove) ->

  function get-spec-signin handle, is-ok, fields then
    info: "signin #{if is-ok then '' else 'bad '}#handle #{JSON.stringify fields}"
    fn  : H.run -> create handle, is-ok, fields

  function get-spec-tests handle, fields then
    ok : get-spec-signin handle, true , fields
    bad: get-spec-signin handle, false, fields

  function get-spec handle then
    signin:
      password:
        a: get-spec-tests handle, password:\Pass1!
        b: get-spec-tests handle, password:\Pass2!
      bad:
        handle  : get-spec-signin \badhandle, false, password:\Pass1!
        password: get-spec-signin handle    , false, password:\badpass

  admin: get-spec \admin
  a: get-spec \usera
  b: get-spec \userb
  signout:
    ok:
      info: "signout"
      fn  : H.run remove
