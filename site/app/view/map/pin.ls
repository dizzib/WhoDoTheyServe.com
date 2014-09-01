F = require \fs
_ = require \underscore
H = require \../../helper

H.insert-css F.readFileSync __dirname + \/pin.css

const SIZE  = 20

module.exports =
  init: (svg, d3f) ->
    log \init
    pin = svg.selectAll \g.node
      .append \g
        .attr \class, ->
          state = if it.px % 2 then '' else \out
          "pin #state"
        .attr \transform, "translate(-0, #SIZE)"
    pin.append \text
      .attr \class, \fa
      .attr \font-family, \FontAwesome
      .attr \font-size, SIZE
      .text \\uf08d
    # include this path to show bounding box for debugging pin rotation
    #pin.append \svg:path .attr \d, "M -#{l = SIZE / 2} -#l L #l -#l L #l #l L -#l #l L -#l -#l"

    $ \.map .on \click, \.pin ->
      log it, this
      $pin = $ this
      log $pin.parent!attr \class
