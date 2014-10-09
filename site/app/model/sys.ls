B   = require \backbone
Api = require \../api

m = B.DeepModel.extend do
  urlRoot: Api.sys

  ## core
  toJSON-T: -> @toJSON it

module.exports = m
