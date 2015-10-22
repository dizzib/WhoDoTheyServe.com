C = require \../../collection
V = require \../../view

module.exports =
  init: ->
    $ \#name .typeahead source:C.Nodes.pluck \name

    map-name = V.map.map?get \name
    $ \input#__add-to-map .prop \disabled !map-name?
    return unless map-name?
    $ \input#__add-to-map~div .append map-name
