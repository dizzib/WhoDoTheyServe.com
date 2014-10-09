B   = require \backbone
_   = require \underscore
Con = require \../../lib/model-constraints
Api = require \../api
Fac = require \./_factory

m = B.DeepModel.extend do
  urlRoot: Api.nodes

  ## core
  toJSON-T: (opts) ->
    function get-family-name node
      return unless name = node.get \name
      name.match(/^\w+,/)?0.replace ',', ''
    _.extend (@toJSON opts),
      family-name: get-family-name this
      tip        : 'Evidence'

  ## extensions
  get-yyyy: ->
    /[12]\d{3}$/.exec(@get \name)?0

  ## validation
  validation:
    'name':
      * required: yes
      * pattern : Con.node.name.regex
        msg     : "Name should be #{Con.node.name.info}"

m.create = Fac.get-factory-method m

module.exports = m
