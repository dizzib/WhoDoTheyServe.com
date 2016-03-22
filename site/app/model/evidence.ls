B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
Api = require \../api
Fac = require \./_factory
Hv  = require \./hive .instance.Evidences

const VID-VIMEO   = service:\vimeo   rx:/vimeo\.com/i
const VID-YOUTUBE = service:\youtube rx:/youtube\.com|youtu\.be/i

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.evidences

  ## core
  toJSON-T: (opts) ->
    url = @get \url
    vid = _.find [ VID-VIMEO, VID-YOUTUBE ], -> it.rx.test url
    if (/^https?:\/\/web\.archive\.org/.test url or @get \bare_href or vid)
      href = url
    else
      unless timestamp = @get \timestamp
        d = new Date @get \meta.create_date
        timestamp = d.getFullYear! + if (m = 1 + d.getMonth!) < 10 then "0#m" else "#m"
      href = "https://web.archive.org/web/#timestamp/#url"

    _.extend (@toJSON opts),
      glyph  : @get-glyph!
      href   : href
      is-dead: @is-dead!
      video  : vid

  ## extensions
  get-glyph: ->
    const GLYPHS =
      * name:\fe-file-pdf unicode:\\ue807 rxs:[ /\.pdf$/i ]
      * name:\fe-videocam unicode:\\ue81c rxs:[ VID-VIMEO.rx, VID-YOUTUBE.rx ]
    url = @get \url
    for g in GLYPHS then return g if _.find g.rxs, -> it.test url
    name:\fe-doc-text unicode:\\ue81b

  is-dead: ->
    _.contains Hv.dead-ids, @id

  ## validation
  labels:
    'url': 'Url'
  validation:
    'timestamp':
      * required: no
      * pattern : Con.timestamp.regex
        msg     : "Timestamp should be #{Con.timestamp.info}"
    'url':
      * required: yes
      * pattern : \url

me.create = Fac.get-factory-method me
