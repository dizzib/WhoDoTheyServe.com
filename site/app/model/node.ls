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
    is-person = Lib.is-person name = @get \name
    w = W.parse-range w-raw = @get \when

    _.extend (@toJSON opts),
      family-name: (name.match(/^\w+,/)?0.replace ',' '') if is-person
      is-live    : W.is-in-range W.get-int-today!, w.int
      is-person  : is-person
      tip        : 'Evidence'
      when-text  : if w-raw then "(#w-raw)" else ''

  ## extensions
  get-yyyy-by-name: ->
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

me.create = Fac.get-factory-method me
