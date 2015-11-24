B = require \backbone
F = require \fs # inlined by brfs
T = require \transparency
_ = require \underscore

T-Sel = F.readFileSync __dirname + \/select.html

# multi-select can't be browserified 'cos it references an adjacent png
B.once \signin -> yepnope.injectCss \/lib-3p/multiple-select.css

module.exports =
  MultiSelectView: B.View.extend do
    get-selected-ids: ->
      @dropdown.multipleSelect \getSelects
    initialize: ->
      @sel  = it.sel
      @opts = it.opts <<<
        placeholder : (get-select-placeholder $ T-Sel).text!
        onCheckAll  : ~> @trigger \checkAll it
        onClick     : ~> @trigger \click it
        onUncheckAll: ~> @trigger \uncheckAll it
    render: (coll, fname, sel-ids = []) ->
      $t-sel = get-select $ T-Sel
      render-select $t-sel, coll, fname
      @dropdown = @$el or $ @sel
        ..html $t-sel.children! # children! prevents duplicate nested select
        ..attr \multiple \multiple
        ..multipleSelect @opts
        ..multipleSelect \setSelects sel-ids

  SelectView: B.View.extend do
    get-selected-id: ->
      @dropdown.val!
    initialize: ->
      @sel = it.sel
    render: (coll, fname, sel-id = '') ->
      $t-sel = get-select $t = $ T-Sel
      render-select $t-sel, coll, fname
      if not coll.findWhere or coll.findWhere _id:sel-id .length is 0
        $t-sel.prepend get-select-placeholder $t
      @dropdown = (if @sel then $ @sel else @$el)
      _.defer ~> @set-by-id sel-id
      @dropdown
        ..html $t-sel.children! # children! prevents duplicate nested select
        ..combobox bsVersion:2
        ..change ~> @trigger \selected @get-selected-id!
    set-by-id: ->
      @dropdown.val it
      cbx = @dropdown.data \combobox
      cbx.$element.val '' if it is '' # cbx.clearElement! causes focus problems
      cbx.refresh!

## helpers

function get-select $tem
  $tem.filter \select

function get-select-placeholder $tem
  $tem.filter \.placeholder .find \option

function render-select $el, coll, fname
  items = if coll.toJSON? then coll.toJSON! else coll
  $el.render items, item:
    html : -> @[fname]
    value: -> @_id
