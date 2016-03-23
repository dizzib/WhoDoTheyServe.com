B   = require \backbone
_   = require \underscore
Con = require \../../lib/model/constraints
Api = require \../api
Fac = require \./_factory

module.exports = me = B.DeepModel.extend do
  urlRoot: Api.evidences

  ## core
  toJSON-T: (opts) ->
    const DEFS =
      pdf:
        glyph: name:\fe-file-pdf unicode:\\ue807
        rx   : /\.pdf$/i
        type : \binary
      vimeo:
        glyph: name:\fe-videocam unicode:\\ue81c
        rx   : /vimeo\.com/i
        type : \binary
        video:
          service:\vimeo
      youtube:
        glyph: name:\fe-videocam unicode:\\ue81c
        rx   : /youtube\.com|youtu\.be/i
        type : \binary
        video:
          service:\youtube
      default:
        glyph: name:\fe-doc-text unicode:\\ue81b
        rx   :  /.+/
        type : \text

    o = _.extend @toJSON(opts), _.find DEFS, ~> it.rx.test @get \url
    o.is-bare = o.bare_href or o.type is \binary
    if o.video?service is \youtube
      # http://stackoverflow.com/questions/21607808/convert-a-youtube-video-url-to-embed-code
      matches = o.url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
      o.video.href = "//www.youtube.com/embed/#{o.video.id = id}" if (id = matches?2)?length is 11
    if (/^https?:\/\/web\.archive\.org/.test o.url or o.is-bare)
      o.href = o.url
    else
      unless timestamp = o.timestamp
        d = new Date @get \meta.create_date
        timestamp = d.getFullYear! + if (m = 1 + d.getMonth!) < 10 then "0#m" else "#m"
      o.href = "http://web.archive.org/web/#timestamp/#{o.url}"
    o

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
