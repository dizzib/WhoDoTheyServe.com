const LIBS =
  backbone:
    cdn: \backbone.js/1.0.0/backbone-min.js
    loc: \backbone.js
    ok : -> Backbone?
  backbone_validation:
    cdn: \backbone.validation/0.7.1/backbone-validation-min.js
    loc: \backbone-validation.js
    ok : -> Backbone?.Validation?
  bootstrap_css:
    cdn: \twitter-bootstrap/2.3.1/css/bootstrap.min.css
    loc: \bootstrap/css/bootstrap.css
    ok : -> true # no fallback 'cos yepnope.css.js ignores timeout
  bootstrap_typeahead:
    cdn: \twitter-bootstrap/2.3.1/js/bootstrap-typeahead.min.js
    loc: \bootstrap/js/bootstrap-typeahead.js
    ok : -> $?.fn.typeahead?
  d3:
    cdn: \d3/3.1.6/d3.min.js
    loc: \d3.js
    ok : -> d3?
  jquery:
    cdn: \jquery/2.0.1/jquery.min.js
    loc: \jquery.js
    ok : -> $?
  jquery_timeago:
    cdn: \jquery-timeago/1.1.0/jquery.timeago.min.js
    loc: \jquery.timeago.js
    ok : -> $?.timeago?
  underscore:
    cdn: \underscore.js/1.4.4/underscore-min.js
    loc: \underscore.js
    ok : -> _?

resources = []
resources # order is important for dependencies
  ..push get-resource \underscore
  ..push get-resource \jquery
  ..push get-resource \jquery_timeago
  ..push get-resource \backbone
  ..push get-resource \backbone_validation
  ..push get-resource \bootstrap_css
  ..push get-resource \bootstrap_typeahead
  ..push get-resource \d3
  ..push load:\lib.js
  ..push load:\app.js
yepnope.errorTimeout = 4000ms
yepnope resources

function get-resource name then
  test    : is-load-from-cdn!
  yep     : "//cdnjs.cloudflare.com/ajax/libs/#{LIBS[name].cdn}"
  nope    : get-url-local name
  complete: ->
    console.log name
    return if LIBS[name].ok!
    console.log "Fallback to #{url = get-url-local name}"
    yepnope url

function get-url-local name then "/lib-3p/#{LIBS[name].loc}"

function is-load-from-cdn then
  is-prod = /\.(com|net)$/.test window.location.origin
  is-prod or /cdn/.test window.location.search
