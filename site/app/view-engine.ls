B = require \backbone
F = require \fs # inlined by brfs
T = require \transparency
_ = require \underscore
H = require \./helper
S = require \./session

T-Sel = F.readFileSync __dirname + \/view/select.html

const CLASS-EDITING = \editing

module.exports =
  DocuView: B.View.extend do
    initialize: -> @document = it.document
    render: -> @$el.html @document .show!

  EditView: B.View.extend do
    events:
      'click .cancel': \cancel
      'click .delete': \delete
      'submit form'  : \save
    initialize: ->
      @opts     = it.opts
      @template = it.template
      _.extend this, B.Events
    cancel: -> @trigger \cancelled
    delete: ->
      #TODO: always confirm delete when Marionette is capable of testing it
      if @opts?is-confirm-delete
        return unless confirm 'Are you sure you want to delete this item ?'
      @coll.destroy @model, error:H.on-err, success: ~> @trigger \destroyed, @model
    render: (@model, @coll, opts) ->
      @delegateEvents!
      $ \.view .addClass CLASS-EDITING
      B.Validation.bind this
      ($tem = $ @template).addClass if is-new = @model.isNew! then \create else \update
      return render @model if is-new or opts?fetch is no
      @model.fetch error:H.on-err, success: -> render it
      ~function render model then
        @$el.html $tem.render model.toJSON-T! .set-access S .show!
        @$el.find 'input[type=text],textarea,select' .filter \:visible:first .focus!
        @trigger \rendered, model
    save: ->
      it.preventDefault!
      unless (m = @model) then alert "ERROR! @model is void. Check $el isn't used by other edit views!"
      is-new = m.isNew!
      m.attributes = $ it.currentTarget .serializeObject!
      @trigger \serialized, m
      @coll.create m, { +merge, +wait, error:H.on-err, success: ~> @trigger \saved, m, is-new }
      false
  ResetEditView: -> $ \.view .removeClass CLASS-EDITING

  InfoView: B.View.extend do
    initialize: -> @template = it.template
    render: (model, directive) ->
      data = if model then model.toJSON-T! else {}
      # NOTE: transparency won't process directive if data is void, hence {}
      ($tem = $ @template).render data, directive
      @$el.html $tem .set-access S .show!

  ListView: B.View.extend do
    initialize: ->
      @opts     = { fetch:true } <<< it.opts
      @template = it.template
    # For fast ui render happens in 2 passes:
    # 1. render current content immediately
    # 2. render async-fetched content
    render: (coll, directive, opts) ->
      @$el.attr \data-loc, B.history.fragment # to detemine if navigated away
      render coll, 0
      return unless @opts.fetch
      return unless coll.url # filtered collection won't have url
      coll.fetch error:H.on-err, success: -> render it, 1
      ~function render c, pass then
        return unless B.history.fragment is @$el.attr \data-loc # bail if user has navigated away
        c = c.find f if f = opts?filter
        return opts?void-view.render! if c.length is 0
        ($tem = $ @template).filter \.items .render c.toJSON-T!, directive
        @$el.html $tem
        @$el.set-access S .show! if pass is 0

  MultiSelectView: B.View.extend do
    get-selected-ids: -> @dropdown.multipleSelect \getSelects
    initialize: ->
      @sel  = it.sel
      @opts = it.opts <<<
        placeholder : (get-select-placeholder $ T-Sel).text!
        onCheckAll  : ~> @trigger \checkAll  , it
        onClick     : ~> @trigger \click     , it
        onUncheckAll: ~> @trigger \uncheckAll, it
    render: (coll, fname, sel-ids = []) ->
      $t-sel = get-select $ T-Sel
      render-select $t-sel, coll, fname
      @dropdown = $ @sel
        ..html $t-sel.children! # children! prevents duplicate nested select
        ..attr \multiple, \multiple
        ..multipleSelect @opts
        ..multipleSelect \setSelects, sel-ids

  SelectView: B.View.extend do
    get-selected-id: -> @dropdown.val!
    initialize: -> @sel = it.sel
    render: (coll, fname, sel-id = '') ->
      $t-sel = get-select $t = $ T-Sel
      render-select $t-sel, coll, fname
      if coll.findWhere _id:sel-id .length is 0 then $t-sel.prepend get-select-placeholder $t
      @dropdown = $ @sel
        ..html $t-sel.children! # children! prevents duplicate nested select
        ..val sel-id
        ..combobox bsVersion:2
        ..change ~> @trigger \selected

# helpers

function get-select             $tem then $tem.filter \select
function get-select-placeholder $tem then $tem.filter \.placeholder .find \option

function render-select $sel, coll, fname
  $sel.render coll.toJSON!, item:
    html : -> @[fname]
    value: -> @_id
