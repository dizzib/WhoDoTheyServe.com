B   = require \backbone
_   = require \underscore
Api = require \../api
Fac = require \./_factory
Hv  = require \./hive .instance.Evidences

const VID-VIMEO   = service:\vimeo   rx:/vimeo\.com/i
const VID-YOUTUBE = service:\youtube rx:/youtube\.com|youtu\.be/i

m = B.DeepModel.extend do
  urlRoot: Api.evidences

  ## core
  toJSON-T: (opts) ->
    _.extend (@toJSON opts),
      glyph  : @get-glyph!
      is-dead: @is-dead!
      video  : _.find [ VID-VIMEO, VID-YOUTUBE ], ~> it.rx.test @get \url

  ## extensions
  get-glyph: ->
    const GLYPHS =
      * name:\fe-file-pdf unicode:\\ue807 rxs:[ /\.pdf$/i ]
      * name:\fe-videocam unicode:\\ue81c rxs:[ VID-VIMEO.rx, VID-YOUTUBE.rx ]
    for g in GLYPHS then return g if _.find g.rxs, ~> it.test @get \url
    name:\fe-doc-text unicode:\\ue81b

  is-dead: ->
    _.contains Hv.dead-ids, @id

  ## validation
  labels    : 'url': 'Url'
  validation: 'url': required:yes pattern:\url

m.create = Fac.get-factory-method m

module.exports = m
