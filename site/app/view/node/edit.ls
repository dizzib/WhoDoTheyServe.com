Con = require \../../../lib/model/constraints
N   = require \../../../lib/model/node
C   = require \../../collection
V   = require \../../view

const STORE-KEY = \node/edit/add-to-map

module.exports =
  init: ->
    # name
    function show-or-hide-person-glyph then $ \.person-glyph .toggle N.is-person $name.val!
    ($name = @$ \#name).typeahead source:C.Nodes.pluck \name
    $name.on 'change keyup' show-or-hide-person-glyph
    show-or-hide-person-glyph!

    # tags
    $.extend $.fn.typeahead.Constructor.prototype, val: -> # fix tagsinput #436
    ($tags = @$ \#tags).tagsinput typeahead: source:C.Nodes.tags!
    for tag in @model.get(\tags) or [] then $tags .tagsinput \add tag

    # add-to-map
    return @$ \.add-to-map .hide! unless map-name = get-map-name!
    @$ \#__add-to-map .prop \checked (\true is localStorage.getItem STORE-KEY)
    @$ \#__add-to-map~div .append map-name

  save: ->
    # add-to-map
    return unless get-map-name!
    add2map = @$ \#__add-to-map .prop \checked
    localStorage.setItem STORE-KEY, add2map

function get-map-name then V.maps.get-current!?get \name
