_      = require \lodash
Assert = require \assert
Shell  = require \shelljs/global
WFor   = require \wait.for .for
W4m    = require \wait.for .forMethod
Dir    = require \./constants .dir.site

mkdir Dir.SEO unless test '-e', Dir.SEO

module.exports =
  generate: ->
    log 'generate seo'
    void

## helpers

