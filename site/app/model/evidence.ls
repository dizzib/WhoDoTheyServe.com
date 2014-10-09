B   = require \backbone
_   = require \underscore
Fac = require \./_factory
Api = require \../api
C   = require \../collection

const VID-VIMEO   = service:\vimeo   rx:/vimeo\.com/i
const VID-YOUTUBE = service:\youtube rx:/youtube\.com|youtu\.be/i

m = B.DeepModel.extend do
  urlRoot: Api.evidences

  ## core
  toJSON-T: (opts) ->
    _.extend (@toJSON opts),
      glyph: @get-glyph!
      video: _.find [ VID-VIMEO, VID-YOUTUBE ], ~> it.rx.test @get \url

  ## extensions
  get-glyph: ->
    const GLYPHS =
      * name:\fa-file-pdf-o   unicode:\\uf1c1 rxs:[ /\.pdf$/i ]
      * name:\fa-video-camera unicode:\\uf03d rxs:[ VID-VIMEO.rx, VID-YOUTUBE.rx ]
    for g in GLYPHS then return g if _.find g.rxs, ~> it.test @get \url
    name:\fa-file-text-o unicode:\\uf0f6

  ## validation
  labels    : 'url': 'Url'
  validation: 'url': required:yes pattern:\url

m.create = Fac.get-factory-method m

module.exports = m
