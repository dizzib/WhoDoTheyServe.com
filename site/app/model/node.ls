B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
Lib = require \../../lib/model/node
Api = require \../api
Fac = require \./_factory

m = B.DeepModel.extend do
  urlRoot: Api.nodes

  ## core
  toJSON-T: (opts) ->
    name = @get \name
    is-person = Lib.is-person name
    _.extend (@toJSON opts),
      family-name: (name.match(/^\w+,/)?0.replace ',' '') if is-person
      is-person  : is-person
      tip        : 'Evidence'

  ## extensions
  get-yyyy: ->
    /[12]\d{3}$/.exec(@get \name)?0

  ## validation
  validation:
    name:
      * required: yes
      * pattern : Con.node.name.regex
        msg     : "Name should be #{Con.node.name.info}"
    tags: ->
      const MSG = "Every tag should be #{Con.node.tag.info}"
      tags = if _.isString it then [it] else it
      MSG unless tags and tags.every -> Con.node.tag.regex.test it

m.create = Fac.get-factory-method m

module.exports = m
