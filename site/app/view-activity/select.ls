B = require \backbone
F = require \fs # inlined by brfs
T = require \transparency

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
      @dropdown = $ @sel
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
      if coll.findWhere _id:sel-id .length is 0 then $t-sel.prepend get-select-placeholder $t
      @dropdown = $ @sel
        ..html $t-sel.children! # children! prevents duplicate nested select
        ..val sel-id
        ..combobox bsVersion:2
        ..change ~> @trigger \selected
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

function render-select $sel, coll, fname
  $sel.render coll.toJSON!, item:
    html : -> @[fname]
    value: -> @_id
