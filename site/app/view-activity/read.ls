B = require \backbone
Q = require \querystring # browserified
T = require \transparency
S = require \../session

module.exports =
  DocuView: B.View.extend do
    initialize: -> @document = it.document
    render: -> @$el.html @document .show!

  InfoView: B.View.extend do
    initialize: ->
      @opts     = it.opts or {}
      @template = it.template
    render: (o, directive) ->
      # transparency won't process void data, hence {}
      data = if @opts.query-string then Q.parse o else (o?toJSON-T! or {})
      ($tem = $ @template).render data, directive
      @$el.html $tem .set-access S .show!
      @trigger \rendered o

  ListView: B.View.extend do
    initialize: ->
      @opts     = { fetch:true } <<< it.opts
      @template = "<div>#{it.template}</div>" # transparency requires a root div for lists
    # For fast ui render happens in 2 passes:
    # 1. render current content immediately
    # 2. render async-fetched content
    render: (coll, directive, opts) ->
      @$el.attr \data-loc B.history.fragment # to detemine if navigated away
      render coll, 0
      return unless @opts.fetch
      return unless coll.url # filtered collection won't have url
      coll.fetch success: -> render it, 1
      ~function render c, pass
        return unless B.history.fragment is @$el.attr \data-loc # bail if user has navigated away
        c = c.find f if f = opts?filter
        ($tem = $ @template).render (items:c.toJSON-T!), items:directive
        $tem.find \.no-items .toggle (c.length is 0)
        @$el.html $tem
        @$el.set-access S .show! if pass is 0
