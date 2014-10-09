B   = require \backbone
Con = require \../../lib/model-constraints
Api = require \../api
Fac = require \./_factory

m = B.DeepModel.extend do
  urlRoot: Api.notes

  ## core
  toJSON-T: -> @toJSON it

  ## validation
  validation:
    'text':
      * required: yes
      * pattern : Con.note.regex
        msg     : "Note should be #{Con.note.info}"

m.create = Fac.get-factory-method m

module.exports = m
