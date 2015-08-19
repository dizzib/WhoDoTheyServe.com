Sh  = require \shelljs/global
Dir = require \./constants .dir

module.exports = ->
  if test \-e src = "#{Dir.BUILD}/package.json"
    cp \-f src, Dir.ROOT

    o = JSON.parse cat src
    delete o.devDependencies
    delete o.scripts.task
    delete o.scripts.test
    json = JSON.stringify o, void, 2
    json.to "#{Dir.build.SITE}/package.json"
