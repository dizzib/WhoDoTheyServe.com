B   = require \backbone
Api = require \../api

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.sys

  ## core
  toJSON-T: -> @toJSON it

me.instance = new me!
  ..on \sync, -> # set convenience properties
    @env = @get \env

B.on \boot -> me.instance.fetch!
