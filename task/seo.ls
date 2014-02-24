_      = require \lodash
Assert = require \assert
Shell  = require \shelljs/global
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod

const OBJ = pwd!
const SEO = OBJ.replace /_build\/obj$/, \_build/seo

Assert SEO isnt OBJ
mkdir SEO unless test '-e', SEO

module.exports =
  generate: ->
    log 'generate seo'
    void

## helpers

