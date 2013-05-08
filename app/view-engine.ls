B = require \backbone
F = require \fs
T = require \transparency
_ = require \underscore
H = require \./helper

T-Sel = F.readFileSync __dirname + \/view/select.html

exports
  ..DocuView = B.View.extend do
    render: -> @$el.html @options.document .show!

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
        @$el.html $tem.render model.toJSON-T! .set-access!show!
        @$el.find 'input[type=text],textarea,select' .filter ':visible:first' .focus!
        @trigger \rendered, model
    save: ->
      # if @model is undefined here then check $el isn't being used elsewhere!
      (m = @model).attributes = $ it.currentTarget .serializeObject!
      @coll.create m, { +merge, +wait, error:H.on-err, success: ~> @trigger \saved, @model }
      false

  ..InfoView = B.View.extend do
    render: (model, directive) ->
      data = if model then model.toJSON-T! else {}
      # NOTE: transparency won't process directive if data is void, hence {}
      ($tem = $ @options.template).render data, directive #, debug:on
      @$el.html $tem .set-access!show!

  ..ListView = B.View.extend do
    render: (coll, directive, opts) ->
      return render coll if opts?fetch is no
      return render coll unless coll.url
      coll.fetch error:H.on-err, success: -> render it
      ~function render c then
        c = c.find f if f = opts?filter
        if c.length is 0 then
          return unless opts?void-view
          return opts.void-view.render!
        ($tem = $ @options.template).filter \.items .render c.toJSON-T!, directive
        @$el.html $tem .set-access!show!

  ..SelectView = B.View.extend do
    render: (coll, fname, sel-id) ->
      $T-Sel = $ T-Sel .filter \select .render coll.toJSON!, item:
        html    : -> @[fname]
        selected: -> \selected if @_id is sel-id
        value   : -> @_id
      if $T-Sel.find 'option[selected]' .length is 0 then
        $ T-Sel .filter \.prompt .find \option .prependTo $T-Sel
      $ @tagName .html $T-Sel.children! # children! prevents duplicate nested select
