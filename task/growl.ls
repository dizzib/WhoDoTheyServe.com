_      = require \lodash
Assert = require \assert
Chalk  = require \chalk
G      = require \growler
U      = require \util

const TITLE = 'wdts'

g = void

exports.get = (cb) ->
  return cb void, g if g?

  Assert (host = process.env.growl_at), "config growl_at not found in env"
  g := new G.GrowlApplication TITLE, hostname:host
  g.setNotifications default:void Success:void Error:void
  # for some reason Wait.for doesn't play nice with Growler
  # so stick with a standard callback
  ok, e <- g.register
  return cb e if e?

  g.alert = (e, opts) -> g.err e, opts <<< sticky:true
  g.ok = (text, opts) -> g.say text, true, opts
  g.err = (e, opts) ->
    g.say if e instanceof Error then e.message else e, false, opts
  g.say = (text, ok, opts = {}) ->
    status = if ok then \Success else if ok? then \Error else \default
    chalks = default:\stripColor Success:\green Error:\red
    U.log Chalk[chalks[status]] text unless opts.nolog
    g.sendNotification status, { text:text, title:TITLE } <<< opts
    text

  cb void, g
