const LIBS =
  backbone:
    cdn: '//cdn.jsdelivr.net/backbonejs/1.1.2/backbone-min.js'
    loc: \backbone.js
    ok : -> Backbone?
  bootstrap_css:
    cdn: '//maxcdn.bootstrapcdn.com/bootstrap/2.3.2/css/bootstrap.min.css'
    loc: \bootstrap/css/bootstrap.css
    ok : -> true # no fallback 'cos yepnope.css.js ignores timeout
  d3:
    cdn: '//cdn.jsdelivr.net/d3js/3.4.12/d3.min.js'
    loc: \d3.js
    ok : -> d3?
  font_awesome_css:
    cdn: '//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css'
    loc: \font-awesome-4.2.0/css/font-awesome.css
    ok : -> true # no fallback 'cos yepnope.css.js ignores timeout
  jquery:
    cdn: '//cdn.jsdelivr.net/jquery/2.0.1/jquery.min.js'
    loc: \jquery.js
    ok : -> $?
  underscore:
    cdn: '//cdn.jsdelivr.net/underscorejs/1.7.0/underscore-min.js'
    loc: \underscore.js
    ok : -> _?

resources = []
resources # order is important for dependencies
  ..push get-resource \underscore
  ..push get-resource \jquery
  ..push get-resource \backbone
  ..push get-resource \bootstrap_css
  ..push get-resource \font_awesome_css
  ..push get-resource \d3
  ..push load:\lib.js
  ..push load:\app.js
yepnope.errorTimeout = 2500ms
yepnope resources

function get-resource name
  test    : window.is-load-from-cdn and LIBS[name].cdn # set by /task/staging.ls
  yep     : LIBS[name].cdn
  nope    : get-url-local name
  complete: ->
    #console.log name
    return if LIBS[name].ok!
    console.log "Fallback to #{url = get-url-local name}"
    yepnope url

function get-url-local name then "/lib-3p/#{LIBS[name].loc}"
