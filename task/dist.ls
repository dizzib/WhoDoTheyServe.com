Sh  = require \shelljs/global
Dir = require \./constants .dir

module.exports = ->
  if test \-e src = "#{Dir.BUILD}/package.json"
    cp \-f src, Dir.ROOT

    json = require src
    delete json.devDependencies
    delete json.scripts.task
    delete json.scripts.test
    (JSON.stringify json, void, 2).to "#{Dir.build.SITE}/package.json"
