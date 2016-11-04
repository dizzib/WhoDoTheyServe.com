Mc  = require \marionette-client
Mjl = require \marionette-js-logger
Os  = require \os
_   = require \lodash
U   = require \util
V   = require \variadic.js
W4  = require \wait.for .for
W4m = require \wait.for .forMethod

const POLL-TIME    = 50ms
const SITE-URL     = "http://#{process.env.SITE_DOMAIN_NAME or \localhost}:#{process.env.SITE_PORT}"
const WAIT-TIMEOUT = _.parseInt(process.env.APP_TEST_TIMEOUT) or 15000ms

log "App test timeout = #{WAIT-TIMEOUT}ms"

md = new Mc.Drivers.Tcp host:(host = process.env.firefox-host or \localhost)
mc = new Mc.Client md
mc.protocol = 3
mc.plugin \logger Mjl

module.exports = B =
  assert:
    ok: (is-ok = true) ->
      B.assert.displayed !is-ok, class:\alert-error.active include-hidden:true

    count: (n-expect, opts) ->
      sig = "count(#n-expect, #{U.inspect opts})"
      poll-for-ok WAIT-TIMEOUT, ->
        try
          n-actual = B.wait-for (opts <<< expect-unique:false)
          if n-actual > 0
            el = remote-exec -> testUtils.el
            vis = W4m el, \displayed
            return "#sig: el is not visible" unless vis
          return \ok if n-actual is n-expect
          "#sig expect=#n-expect, actual=#n-actual"
        catch e
          log \count e
          "count failed: #e"

    displayed: (expect = true ...args) ->
      poll-for-ok WAIT-TIMEOUT, ->
        try
          B.wait-for ...args
          el = remote-exec -> testUtils.el
          res = W4m el, \displayed
          return \ok if res is expect
          html = remote-exec -> testUtils.el.outerHTML
          "displayed(#{U.inspect ...args}) expect=#expect, actual=#res, html=#html"
        catch e
          log \displayed e
          "displayed failed: #e"

  click: (...args) ->
    B.wait-for ...args
    remote-exec -> testUtils.click-el!
    B

  fill: (sel, val) ->
    function fill-field label-text, val
      return unless val?
      # val is either a string or {value, opts}
      v = if _.has val, \value then val.value else val
      return unless v?
      B.wait-for label-text, \label val.opts
      remote-exec (-> testUtils.fill it), [ v ]

    if val? then fill-field ...
    else for [k, v] in _.toPairs sel then fill-field k, v

  go: (path = '') ->
    url = "#SITE-URL#{if path then '/#' else ''}/#path"
    remote-exec (-> window.location.href = it), [ url ]

  init: ->
    log "connecting to firefox marionette at #host"
    W4m md, \connect
    log "connected"
    w4mc \startSession
    mc.logger.handleMessage = handle-remote-log
    w4mc \setSearchTimeout 500
    w4mc \goUrl SITE-URL
    w4mc \refresh # clear cache
    init-sandbox!

  refresh: ->
    w4mc \refresh
    init-sandbox!

  send-keys: (keys) ->
    el = remote-exec -> testUtils.el
    W4m el, \clear
    W4m el, \sendKeys keys

  wait-for: V ->
    it.string \filter 'a,button,input,label,legend'
      .object \opts
      .regExp \text-rx # text regexp e.g. /(foo|bar)/
      .string \text    # text string for exact match e.g. 'foo'
      .form \text \?opts
      .form \text \filter \?opts
      .form \text-rx \?filter \?opts
      .form \opts
  , (args) ->
    opts = expect-unique:true include-hidden:false scope:\document timeout:WAIT-TIMEOUT
    opts <<< args.opts

    filter = switch
    | opts.class? => ".#{opts.class}"
    | opts.id?    => "##{opts.id}".replace \. '\\.' # foo.bar is not class .bar
    | _           => opts.sel || args.filter

    sel = args.text || args.'text-rx'?toString!slice(1, -1) || void
    remote-args = [ sel, filter, opts.scope, opts.include-hidden ]

    remote-fn = switch
    | args.text?length => -> testUtils.fetch-by-text ...
    | args.'text-rx'?  => -> testUtils.fetch-by-regex ...
    | _                => -> testUtils.fetch ...

    n = void
    poll-for-ok opts.timeout, ->
      n := remote-exec remote-fn, remote-args
      return \ok if n is 1 or not opts.expect-unique
      "Found #{n} occurrences of #{U.inspect remote-args} expecting exactly 1."
    n

  wait-for-visible: ->
    B.assert.displayed true ...&

## helpers

function handle-remote-log
  log "[marionette log] #{msg = it.message}"
  # any browser error should halt the test run
  # update: commented out since sometimes we want to log html containing 'error'
  # TODO: find a better way
  #throw new Error msg if /error/i.test msg

function init-sandbox
  view = w4mc \findElement \.view
  w4mc \waitFor -> view.displayed!
  remote-exec ->
    log = -> console.log ...&

    testUtils.click-el = ->
      tag = (el = testUtils.el).tagName
      return el.click! unless tag is \A
      # for some reason anchor clicks occasionally fail (bug in firefox?)
      # so we must verify it worked
      href-from = window.location.href
      href-to   = el.getAttribute \href
      return log 'NO HREF' unless href-to?
      rx = new RegExp "#{href-to}$"
      return if rx.test href-from # bail if href is unchanged
      function verify
        #log \verify, href-to, window.location.href
        return if rx.test window.location.href
        log 'CLICK FAIL', href-from, href-to
        window.location.href = href-to # retry by direct navigation
      # This delay determines how long
      # to wait before verify. It must be long enough to allow the click
      # to take effect, but no longer (otherwise later operations may
      # change the window.location)
      el.click!
      setTimeout verify, 10ms

    testUtils.fetch = (cond-fn = (-> true), filter, scope, include-hidden) ->
      n = 0
      scope-el = switch scope
      | \document  => window.document
      | \el        => testUtils.el
      | \el.parent => testUtils.el.parentNode
      | _          => throw new Error "invalid scope #{scope}"
      for el in scope-el.querySelectorAll filter
        continue if el.disabled
        continue unless cond-fn el.textContent
        if (not include-hidden and is-visible el) or include-hidden
          #console.log 'match:', el.outerHTML, el.offsetWidth, el.offsetHeight
          testUtils.el = el
          n++
      n

    testUtils.fetch-by-text = (text, filter, scope, include-hidden) ->
      testUtils.fetch (-> it.trim() is text), filter, scope, include-hidden

    testUtils.fetch-by-regex = (text-rx, filter, scope, include-hidden) ->
      rx = new RegExp text-rx
      testUtils.fetch (-> rx.test it), filter, scope, include-hidden

    testUtils.fill = ->
      id = testUtils.el.getAttribute \for
      for el in document.querySelectorAll "input##{id},textarea##{id}"
        continue unless is-visible el
        switch attr = el.getAttribute \type
        | \text     => el.value = it
        | \password => el.value = it
        | \radio    => el.checked = it
        return attr

    function is-visible el
      el.offsetWidth > 0 or el.offsetHeight > 0

function poll-for-ok timeout, fn
  start-time = Date.now!
  while true
    return if (res = fn!) is \ok
    #log res
    if Date.now! - start-time > timeout
      throw new Error "#{timeout}ms timeout expired. #{res}"
    W4 pause, POLL-TIME

  function pause ms, cb then setTimeout (-> cb!), ms

function remote-exec fn, args
  opts = name:\executeScript parameters:{ script:fn, args:args, sandbox:\system }
  W4m mc, \_executeScript, opts

function w4mc then W4m mc, ...&
