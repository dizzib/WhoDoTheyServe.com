B   = require \backbone
Api = require \../api
Fac = require \./_factory

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.sessions

  ## core
  toJSON-T: -> @toJSON it

  ## validation
  labels:
    'handle': 'Username'
  validation:
    'handle'  : required:yes
    'password': required:yes

me.create = Fac.get-factory-method me
