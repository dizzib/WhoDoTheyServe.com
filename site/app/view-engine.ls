B = require \backbone
F = require \fs # inlined by brfs
T = require \transparency
_ = require \underscore
H = require \./helper
S = require \./session

const CLASS-EDITING = \editing

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
      #TODO: reinstate dialog when Marionette is capable of testing it
      #return unless confirm 'Are you sure you want to delete this item ?'
      @coll.destroy @model, error:H.on-err, success: ~> @trigger \destroyed, @model
    render: (@model, @coll, opts) ->
      @delegateEvents!
      $ \.view .addClass CLASS-EDITING
      B.Validation.bind this
      ($tem = $ @options.template).addClass if is-new = @model.isNew! then \create else \update
      return render @model if is-new or opts?fetch is no
      @model.fetch error:H.on-err, success: -> render it
      ~function render model then
        @$el.html $tem.render model.toJSON-T! .set-access S .show!
        @$el.find 'input[type=text],textarea,select' .filter \:visible:first .focus!
        @trigger \rendered, model
    save: ->
      unless @model then alert "ERROR! @model is void. Check $el isn't used by other edit views!"
      is-new = @model.isNew!
      (m = @model).attributes = $ it.currentTarget .serializeObject!
      @coll.create m, { +merge, +wait, error:H.on-err, success: ~> @trigger \saved, @model, is-new }
      false
  ..ResetEditView = -> $ \.view .removeClass CLASS-EDITING

  ..InfoView = B.View.extend do
    render: (model, directive) ->
      data = if model then model.toJSON-T! else {}
      # NOTE: transparency won't process directive if data is void, hence {}
      ($tem = $ @options.template).render data, directive
      @$el.html $tem .set-access S .show!

  ..ListView = B.View.extend do
    # For fast ui render happens in 2 passes:
    # 1. render current content immediately
    # 2. render async-fetched content
    render: (coll, directive, opts) ->
      @$el.attr \data-loc, B.history.fragment # to detemine if navigated away
      render coll, 0
      return unless coll.url # filtered collection won't have url
      coll.fetch error:H.on-err, success: -> render it, 1
      ~function render c, pass then
        return unless B.history.fragment is @$el.attr \data-loc # bail if user has navigated away
        c = c.find f if f = opts?filter
        #return opts.void-view.render! if c.length is 0 and opts.void-view?
        if c.length is 0 then
          return unless opts?void-view
          return opts.void-view.render!
        ($tem = $ @options.template).filter \.items .render c.toJSON-T!, directive
        @$el.html $tem
        @$el.set-access S .show! if pass is 0

  ..SelectView = B.View.extend do
    get-selected-id: ->
      $ \option:selected, @dropdown .attr \value
    render: (coll, fname, sel-id) ->
      H.insert-css F.readFileSync __dirname + \/lib-3p/bootstrap-combobox.css
      T-Sel = F.readFileSync __dirname + \/view/select.html
      $T-Sel = ($T = $ T-Sel) .filter \select .render coll.toJSON!, item:
        html    : -> @[fname]
        selected: -> \selected if @_id is sel-id
        value   : -> @_id
      $prompt = $T.filter \.prompt .find \option
      unless $T-Sel.find 'option[selected]' .length then $prompt.attr \selected, ''
      $T-Sel.prepend $prompt
      @dropdown = $ @tagName
        ..html $T-Sel.children! # children! prevents duplicate nested select
        ..combobox!
        ..change ~> @trigger \selected
