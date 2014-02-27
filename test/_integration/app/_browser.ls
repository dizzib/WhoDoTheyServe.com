Mc  = require \marionette-client
Os  = require \os
_   = require \underscore
U   = require \util
V   = require \variadic.js
W4  = require \wait.for .for
W4m = require \wait.for .forMethod

const POLL-TIME = 50ms
const SITE-URL  = "http://#{Os.hostname!}:#{process.env.SITE_PORT}"

md = new Mc.Drivers.Tcp host:(host = process.env.firefox-host)
mc = new Mc.Client md

module.exports = B =
  arrange:
    # TODO: unable to mock window.confirm since
    # marionette client's window instance differs from app's ...why?
    confirm: (ok) ->
      w4mc \executeScript, (-> window.confirm = -> ok), [ ok ]

  assert:
    ok: (is-ok = true) -> B.assert.displayed !is-ok, class:\alert-error

    count: (n-expect, opts) ->
      sig = "count(#n-expect, #{U.inspect opts})"
      poll-for-ok 3000ms, ->
        n-actual = B.wait-for (opts <<< require-unique:false)
        if n-actual > 0
          el = w4mc \executeScript -> window.el
          vis = W4m el, \displayed
          return "#sig: el is not visible" unless vis
        return \ok if n-actual is n-expect
        "#sig expect=#n-expect, actual=#n-actual"

    displayed: (expect = true, ...args) ->
      poll-for-ok 3000ms, ->
        try
          B.wait-for ...args
          el = w4mc \executeScript -> window.el
          res = W4m el, \displayed
          return \ok if res is expect
          html = w4mc \executeScript -> window.el.outerHTML
          "displayed(#{U.inspect ...args}) expect=#expect, actual=#res, html=#html"
        catch e
          log \displayed, e
          "displayed failed: #e"

  click: (...args) ->
    B.wait-for ...args
    w4mc \executeScript -> window.click-el!
    B

  fill: (sel, val) ->
    function fill-field label-text, val
      return unless val?
      B.wait-for label-text, \label
      w4mc \executeScript, (-> window.fill it), [ val ]

    if val? then fill-field ...
    else for [k, v] in _.pairs sel then fill-field k, v

  go: (path = '') ->
    url = "#SITE-URL#{if path then '/#' else ''}/#path"
    w4mc \executeScript, (-> window.location.href = it), [ url ]

  init: ->
    log "connecting to firefox marionette at #host"
    W4m md, \connect
    log "connected"
    w4mc \startSession
    w4mc \setSearchTimeout 500
    w4mc \goUrl SITE-URL
    init-sandbox!

  refresh: ->
    w4mc \refresh
    init-sandbox!

  send-keys: (keys) ->
    el = w4mc \executeScript -> window.el
    W4m el, \clear
    W4m el, \sendKeys, keys

  wait-for: V ->
    it.string \filter, 'a,button,input,label,legend'
      .object \opts
      .regExp \text-rx # text regexp e.g. /(foo|bar)/
      .string \text    # text string for exact match e.g. 'foo'
      .form \text, \?opts
      .form \text, \filter, \?opts
      .form \text-rx, \?filter, \?opts
      .form \opts
  , (args) ->
    #log \wait-for, args
    opts = require-unique:true scope:\document timeout:3000ms
    opts <<< args.opts

    filter = switch
    | opts.class? => ".#{opts.class}"
    | opts.id?    => "##{opts.id}"
    | _           => opts.sel || args.filter

    sel = args.text || args.'text-rx'?toString!slice(1, -1) || void
    remote-args = [ sel, filter, opts.scope ]

    remote-fn = switch
    | args.text?      => -> window.fetch-by-text ...
    | args.'text-rx'? => -> window.fetch-by-regex ...
    | _               => -> window.fetch ...

    n = void
    poll-for-ok opts.timeout, ->
      n := w4mc \executeScript, remote-fn, remote-args
      return \ok if n is 1 or not opts.require-unique
      "Found #{n} occurrences of #{U.inspect remote-args} but require only 1."
    n

  wait-for-visible: ->
    B.assert.displayed true, ...&

## helpers

function init-sandbox
  view = w4mc \findElement, \.view
  w4mc \waitFor -> view.displayed!
  w4mc \executeScript ->
    log = console.log

    window.click-el = ->
      tag = (el = window.el).tagName
      return el.click! unless tag is \A
      # for some reason anchor clicks occasionally fail (bug in firefox?)
      # so we must verify it worked
      old-url = window.location.href
      new-path = el.getAttribute \href
      return log 'NO HREF' unless new-path?
      el.click!
      return if (new RegExp new-path).test old-url
      function verify
        return if old-url isnt window.location.href
        log 'CLICK FAIL', old-url, new-path
        window.location.href = new-path # retry by direct navigation
      # This delay determines how long
      # to wait before verify. It must be long enough to allow the click
      # to take effect, but no longer (otherwise later operations may
      # change the window.location)
      setTimeout verify, 10ms

    window.fetch = (cond-fn = (-> true), filter, scope) ->
      n = 0
      scope-el = switch scope
      | \document  => window.document
      | \el        => window.el
      | \el.parent => window.el.parentNode
      | _          => throw new Error "invalid scope #{scope}"
      for el in scope-el.querySelectorAll filter
        if cond-fn el.textContent
          log el.outerHTML
          window.el = el
          n++
      n

    window.fetch-by-text = (text, filter, scope) ->
      window.fetch (-> it.trim() is text), filter, scope

    window.fetch-by-regex = (text-rx, filter, scope) ->
      rx = new RegExp text-rx
      window.fetch (-> rx.test it), filter, scope

    window.fill = ->
      id = window.el.getAttribute \for
      el = document.querySelector "input##{id},textarea##{id}"
      switch attr = el.getAttribute \type
      | \text     => el.value = it
      | \password => el.value = it
      | \radio    => el.checked = it
      attr

function poll-for-ok timeout, fn
  start-time = Date.now!
  while true
    return if (res = fn!) is \ok
    #log res
    if Date.now! - start-time > timeout
      throw new Error "#{timeout}ms timeout expired. #{res}"
    W4 pause, POLL-TIME

  function pause ms, cb then setTimeout (-> cb!), ms

function w4mc then W4m mc, ...&
