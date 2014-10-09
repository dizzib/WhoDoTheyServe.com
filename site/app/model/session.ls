B   = require \backbone
Api = require \../api
Fac = require \./_factory

m = B.DeepModel.extend do
  urlRoot: Api.sessions

  ## core
  toJSON-T: -> @toJSON it

  ## validation
  labels:
    'handle': 'Username'
  validation:
    'handle'  : required:yes
    'password': required:yes

m.create = Fac.get-factory-method m

module.exports = m
