B = require \backbone
Q = require \querystring # browserified
T = require \transparency
_ = require \underscore

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
      @$el.html $tem .show!
      @trigger \rendered o

  ListView: B.View.extend do
    initialize: ->
      @opts     = it.opts or {}
      @template = "<div>#{it.template}</div>" # transparency requires a root div for lists
    render: (coll, directive, opts) ->
      @$el.show!attr \data-loc B.history.fragment # to detemine if navigated away
      # 1. render current content immediately for performance
      render coll, first-chunk-only:@opts.fetch
      # 2. then optionally render async-fetched content
      if @opts.fetch then coll.fetch success: -> render it

      ~function render c, opts, pos = 0
        const CHUNK-SIZE = 5
        return unless B.history.fragment is @$el.attr \data-loc # bail if user has navigated away
        chunk = []
        first-chunk = pos is 0
        while chunk.length < CHUNK-SIZE and pos < c.length
          chunk.push c.at(pos++).toJSON-T!
        ($tem = $ @template).render {items:chunk}, items:directive
        $tem.find \.no-items .toggle c.length is 0
        if first-chunk
          @$el.html $tem
          return if opts?first-chunk-only
        else @$el.find \ul .append $tem.find(\ul).children!
        if pos < c.length then _.defer ~> render c, void, pos
