B = require \backbone
F = require \fs
T = require \transparency
_ = require \underscore
H = require \./helper
S = require \./session

T-Sel = F.readFileSync __dirname + \/view/select.html

exports
  ..DocuView = B.View.extend do
    render: -> @$el.html @options.document .show!

  # IMPORTANT! Every edit view must reside on it's own $el to keep events independent
  ..EditView = B.View.extend do
    events:
      'click .cancel': \cancel
      'click .delete': \delete
      'submit form'  : \save
    initialize: -> _.extend this, B.Events
    cancel: -> @trigger \cancelled
    delete: ->
      return unless confirm 'Are you sure you want to delete this item ?'
      @coll.destroy @model, error:H.on-err, success: ~> @trigger \destroyed, @model
    render: (@model, @coll, opts) ->
      $ \.view .addClass \editing
      B.Validation.bind this
      ($tem = $ @options.template).addClass if is-new = @model.isNew! then \create else \update
      return render @model if is-new or opts?fetch is no
      @model.fetch error:H.on-err, success: -> render it
      ~function render model then
        @$el.html $tem.render model.toJSON-T! .set-access S .show!
        @$el.find 'input[type=text],textarea,select' .filter ':visible:first' .focus!
        @trigger \rendered, model
    save: ->
      unless @model then alert "ERROR! @model is void. Check $el isn't used by other edit views!"
      (m = @model).attributes = $ it.currentTarget .serializeObject!
      @coll.create m, { +merge, +wait, error:H.on-err, success: ~> @trigger \saved, @model }
      false

  ..InfoView = B.View.extend do
    render: (model, directive) ->
      data = if model then model.toJSON-T! else {}
      # NOTE: transparency won't process directive if data is void, hence {}
      ($tem = $ @options.template).render data, directive
      @$el.html $tem .set-access S .show!

  ..ListView = B.View.extend do
    # For fast ui, render happens in 2 phases:
    # 1. render current content immediately; 2. render async-fetched content
    render: (coll, directive, opts) ->
      @$el.attr \data-loc, B.history.fragment # to detemine if navigated away
      return render coll unless coll.url      # filtered collection won't have url
      render coll
      coll.fetch error:H.on-err, success: -> render it, show:false
      ~function render c, opts then
        return unless B.history.fragment is @$el.attr \data-loc # bail if user has navigated away
        c = c.find f if f = opts?filter
        if c.length is 0 then
          return unless opts?void-view
          return opts.void-view.render!
        ($tem = $ @options.template).filter \.items .render c.toJSON-T!, directive
        @$el.html $tem
        @$el.set-access S .show! unless opts?show is false

  ..SelectView = B.View.extend do
    render: (coll, fname, sel-id) ->
      $T-Sel = $ T-Sel .filter \select .render coll.toJSON!, item:
        html    : -> @[fname]
        selected: -> \selected if @_id is sel-id
        value   : -> @_id
      if $T-Sel.find 'option[selected]' .length is 0 then
        $ T-Sel .filter \.prompt .find \option .prependTo $T-Sel
      $ @tagName .html $T-Sel.children! # children! prevents duplicate nested select
