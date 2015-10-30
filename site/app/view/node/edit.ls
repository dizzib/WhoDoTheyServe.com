C = require \../../collection
V = require \../../view

const STORE-KEY = \node/edit/add-to-map

module.exports =
  init: ->
    $ \#name .typeahead source:C.Nodes.pluck \name

    return $ \.add-to-map .hide! unless map-name = get-map-name!
    $ \#__add-to-map .prop \checked (\true is localStorage.getItem STORE-KEY)
    $ \#__add-to-map~div .append map-name

  save: ->
    return unless get-map-name!
    add2map = $ \#__add-to-map .prop \checked
    localStorage.setItem STORE-KEY, add2map

function get-map-name then V.maps.get-current!?get \name
