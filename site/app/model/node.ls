B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
Lib = require \../../lib/model/node
W   = require \../../lib/when
Api = require \../api
Fac = require \./_factory

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.nodes

  ## core
  toJSON-T: (opts) ->
    name  = @get \name
    w-raw = @get \when

    _.extend (@toJSON opts),
      is-live    : !w-raw or W.is-in-range W.get-int-today!, W.parse-range(w-raw).int
      is-person  : Lib.is-person name
      name-yyyy  : /[12]\d{3}$/.exec(name)?0
      tip        : 'Evidence'
      when-text  : if w-raw then "(#{w-raw.replace /^-/ \?-})" else ''

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

me.create = Fac.get-factory-method me
