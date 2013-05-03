_ = require \underscore
S = require \../state

exports.get-spec = (create, remove) ->
  return
    admin: get-spec \admin
    a: get-spec \usera
    b: get-spec \userb
    signout:
      ok:
        info: "signout"
        fn  : remove

  function get-spec login then
    signin:
      password:
        a: get-spec-tests login, password:\Pass1!
        b: get-spec-tests login, password:\Pass2!
      bad:
        login   : get-spec-signin \badlogin, false, password:\Pass1!
        password: get-spec-signin login    , false, password:\badpass

  function get-spec-tests login, fields then
    _.extend do
      ok : get-spec-signin login, true , fields
      bad: get-spec-signin login, false, fields

  function get-spec-signin login, is-ok, fields then
    info: "signin #{login} #{JSON.stringify fields}#{is-ok ? '' : ' bad'}"
    fn  : (done) -> create login, done, is-ok, fields
