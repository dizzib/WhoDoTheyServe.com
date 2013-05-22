_ = require \underscore
H = require \./helper

exports.get-spec = (c, r, u, d, list, verify) ->
  h = new H \user, c, r, u, d, list
  return
    admin: _.extend do
      get-spec-admin!
      token:
        fake      : get-spec-admin token:\ThisIsAFakeToken
    a: _.extend do
      get-spec-a!
      quota-daily:
        six       : get-spec-a quota_daily:6
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
    b: h.get-spec \userb
    c: h.get-spec \userc
    d: h.get-spec \userd
    e: h.get-spec \usere
    login:
      num1      : h.get-spec \1xxx      , password:\aaaA1!
      num2      : h.get-spec \x2xx      , password:\aaaA1!
      num3      : h.get-spec \xx3x      , password:\aaaA1!
      num4      : h.get-spec \xxx4      , password:\aaaA1!
      min       : h.get-spec \x * 4     , password:\aaaA1!
      min-lt    : h.get-spec \x * 3     , password:\aaaA1!
      max       : h.get-spec \x * 12    , password:\aaaA1!
      max-gt    : h.get-spec \x * 13    , password:\aaaA1!
      has-space : h.get-spec 'has space', password:\aaaA1!
      has-ucase : h.get-spec \hasUcase  , password:\aaaA1!
      has-hyphen: h.get-spec \has-hyphen, password:\aaaA1!
    list:
      is0: h.get-spec-list 0
      is1: h.get-spec-list 1
      is2: h.get-spec-list 2
      is3: h.get-spec-list 3
      is4: h.get-spec-list 4
      is5: h.get-spec-list 5

  function get-spec-admin fields then h.get-spec \admin, fields
  function get-spec-a     fields then h.get-spec \usera, fields
