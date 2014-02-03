C = require \marionette-client
O = require \os
_ = require \underscore
U = require \util
V = require \variadic.js
W = require \wait.for

const POLL-TIME = 50ms
const SITE-URL  = "http://#{O.hostname!}:4001"

driver = new C.Drivers.Tcp host:process.env.FIREFOX_HOST
client = new C.Client driver

M = module.exports =
  arrange:
    # TODO: unable to mock window.confirm since
    # marionette client's window instance differs from app's ...why?
    confirm: (ok) ->
      c \executeScript, (-> window.confirm = -> ok), [ ok ]

  assert:
    ok: (is-ok = true) -> M.assert.displayed !is-ok, class:\alert-error

    displayed: (expect = true, ...args) ->
      M.wait-for ...args
      poll-for-ok 3000ms, ->
        el = c \executeScript -> window.el
        res = W.forMethod el, \displayed
        return \ok if res is expect
        html = c \executeScript -> window.el.innerHTML
        "displayed(#{U.inspect ...args}) 
          expect=#{expect}, actual=#{res}, html=#{html}"

  init: ->
    W.forMethod driver, \connect
    c \startSession
    c \setSearchTimeout 2000
    c \goUrl SITE-URL
    c \executeScript init-sandbox

  click: ->
    M.wait-for ...
    c \executeScript -> window.el.click!
    W.for pause, 50ms # wait-for errors happen without this delay

  fill: (sel, val) ->
    function fill-field label-text, val then
      return unless val?
      M.wait-for label-text, \label
      c \executeScript, (-> window.fill it), [ val ]

    if val? then fill-field ...
    else for [k, v] in _.pairs sel then fill-field k, v

  # client.goUrl has a bug where it freezes on 2nd invocation
  # so we'll roll our own
  go: (path = '') ->
    function nav then window.location.href=it
    url = "#{SITE-URL}#{if path then '/#/' else '/'}#{path}"
    c \executeScript, nav, [ url ]

  pause: (ms = 100ms) ->
    W.for pause, ms

  send-keys: (keys) ->
    el = c \executeScript -> window.el
    W.forMethod el, \clear
    W.forMethod el, \sendKeys, keys

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
    default-opts = require-unique:true scope:\document timeout:3000ms
    opts         = _.extend default-opts, args.opts

    filter      = args.filter
    filter      = ".#{opts.class}" if opts.class?
    filter      = "##{opts.id}" if opts.id?
    filter?     = opts.sel
    sel         = args.text || args.'text-rx'?toString!slice(1, -1) || void
    remote-args = [ sel, filter, opts.scope ]

    remote-fn =
      case args.text?      then -> window.fetch-by-text ...
      case args.'text-rx'? then -> window.fetch-by-regex ...
      default              then -> window.fetch ...

    n = void
    poll-for-ok opts.timeout, ->
      n := c \executeScript, remote-fn, remote-args
      return \ok if n is 1 or not opts.require-unique
      "Found #{n} occurrences of #{U.inspect args}."
    n

## helpers

# synchronously execute marionette client method
function c ...args then W.forMethod client, ...args

function init-sandbox then
  window.fetch = (cond-fn = (-> true), filter, scope) ->
    n = 0
    scope-el = switch scope
      case \document  then window.document
      case \el        then window.el
      case \el.parent then window.el.parentNode
      default         then throw new Error "invalid scope #{scope}"
    for el in scope-el.querySelectorAll filter
      if cond-fn el.textContent then
        window.el = el
        n++
    n

  window.fetch-by-text = (text, filter, scope) ->
    window.fetch (-> it.trim() is text), filter, scope

  window.fetch-by-regex = (text-rxs, filter, scope) ->
    rx = new RegExp text-rxs
    window.fetch (-> rx.test it), filter, scope

  window.fill = ->
    id = window.el.getAttribute \for
    el = document.querySelector "input##{id},textarea##{id}"
    switch attr = el.getAttribute \type
      case \text     then el.value = it
      case \password then el.value = it
      case \radio    then el.checked = it
    attr

function poll-for-ok timeout, fn then
  start-time = Date.now!
  while true
    return if (res = fn!) is \ok
    if Date.now! - start-time > timeout then
      throw new Error "#{timeout}ms timeout expired. #{res}"
    W.for pause, POLL-TIME

function pause ms, cb then
  setTimeout (-> cb!), ms
