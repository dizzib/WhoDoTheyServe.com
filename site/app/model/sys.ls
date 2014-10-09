B   = require \backbone
Api = require \../api

m = B.DeepModel.extend do
  urlRoot: Api.sys

  ## core
  toJSON-T: -> @toJSON it

m.instance = new m!
  ..on \sync, -> # set convenience properties
    @env = @get \env

module.exports = m
