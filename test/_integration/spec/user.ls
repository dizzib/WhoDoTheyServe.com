_ = require \underscore

exports.get-spec = (create, read, update, remove, list, verify) ->
  return
    admin: _.extend do
      get-spec-admin!
      token:
        fake      : get-spec-admin token:\ThisIsAFakeToken
    a: _.extend do
      get-spec-a!
      trust-level:
        six       : get-spec-a trust_level:6
      email:
        null      : get-spec-a email:''
        new       : get-spec-a email:\email@domain.com
        no-domain : get-spec-a email:\email
        no-dot    : get-spec-a email:\email@domain
        no-name   : get-spec-a email:\@domain.com
        mailto    : get-spec-a email:\mailto:email@domain.com
      info:
        no-http   : get-spec-a info:\foo
        no-path   : get-spec-a info:\http://
        no-domain : get-spec-a info:\http://foo
        path      : get-spec-a info:\http://foo.com
        path-qs   : get-spec-a info:\http://foo.com?bar=boo
      password:
        b         : get-spec-a password:\Pass2!
        c         : get-spec-a password:\Pass3!
        min-lt    : get-spec-a password:\aaA1!
        max-gt    : get-spec-a password:\1234567890123aA1!
        weak-num  : get-spec-a password:\aaaaA!
        weak-sym  : get-spec-a password:\aaaaA1
        weak-ucase: get-spec-a password:\aaaa!1
    b: get-spec \userb
    c: get-spec \userc
    d: get-spec \userd
    e: get-spec \usere
    login:
      num1      : get-spec \1xxx      , password:\aaaA1!
      num2      : get-spec \x2xx      , password:\aaaA1!
      num3      : get-spec \xx3x      , password:\aaaA1!
      num4      : get-spec \xxx4      , password:\aaaA1!
      min       : get-spec \x * 4     , password:\aaaA1!
      min-lt    : get-spec \x * 3     , password:\aaaA1!
      max       : get-spec \x * 12    , password:\aaaA1!
      max-gt    : get-spec \x * 13    , password:\aaaA1!
      has-space : get-spec 'has space', password:\aaaA1!
      has-ucase : get-spec \hasUcase  , password:\aaaA1!
      has-hyphen: get-spec \has-hyphen, password:\aaaA1!
    list:
      is0: get-spec-list 0
      is1: get-spec-list 1
      is2: get-spec-list 2
      is3: get-spec-list 3
      is4: get-spec-list 4
      is5: get-spec-list 5

  function get-spec-admin fields then get-spec \admin, fields
  function get-spec-a     fields then get-spec \usera, fields

  function get-spec login, fields then
    _.extend do
      get-spec-tests create, login, fields
      get-spec-tests read  , login, fields
      get-spec-tests update, login, fields
      get-spec-tests remove, login, fields
      get-spec-tests verify, login, fields

  function get-spec-list n then
    info: "user list is #{n}"
    fn  : (done) -> list done, n

  function get-spec-tests op, login, fields then
    "#{op.name}":
      ok : get-spec-test op, login, true , fields
      bad: get-spec-test op, login, false, fields

  function get-spec-test op, login, is-ok, fields then
    info: "#{op.name} user #{login} #{JSON.stringify(fields) ? ''}#{if is-ok then '' else ' bad'}"
    fn  : (done) -> op done, login, is-ok, fields
