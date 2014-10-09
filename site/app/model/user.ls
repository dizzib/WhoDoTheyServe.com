B   = require \backbone
Con = require \../../lib/model-constraints
Api = require \../api
Fac = require \./_factory

m = B.DeepModel.extend do
  urlRoot: Api.users

  ## core
  toJSON-T: -> @toJSON it

  ## extensions
  get-is-admin: -> \admin is @get \role

  ## validation
  labels:
    'info'    : 'Homepage'
    'passconf': 'Confirm Password'
  validation:
    'handle':
      * required: yes
      * pattern : Con.handle.regex
        msg     : "Username should be #{Con.handle.info}"
    'password':
      * required: -> @isNew!
      * pattern : Con.password.regex
        msg     : "Password should be #{Con.password.info}"
    'passconf':
      equalTo: \password
    'email':
      * required: no
      * pattern : Con.email.regex
        msg     : "Email should be #{Con.email.info}"
    'info':
      pattern : \url
      required: no

m.create = Fac.get-factory-method m

module.exports = m
