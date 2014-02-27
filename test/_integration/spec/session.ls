_ = require \underscore
H = require \../helper
S = require \../state

exports.get-spec = (create, remove) ->

  function get-spec-signin login, is-ok, fields then
    info: "signin #{if is-ok then '' else 'bad '}#login #{JSON.stringify fields}"
    fn  : H.run -> create login, is-ok, fields

  function get-spec-tests login, fields then
    ok : get-spec-signin login, true , fields
    bad: get-spec-signin login, false, fields

  function get-spec login then
    signin:
      password:
        a: get-spec-tests login, password:\Pass1!
        b: get-spec-tests login, password:\Pass2!
      bad:
        login   : get-spec-signin \badlogin, false, password:\Pass1!
        password: get-spec-signin login    , false, password:\badpass

  admin: get-spec \admin
  a: get-spec \usera
  b: get-spec \userb
  signout:
    ok:
      info: "signout"
      fn  : H.run remove
