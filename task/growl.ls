Chalk = require \chalk
Gntp  = require \gntp
Util  = require \util

const APPNAME = \wdts
const INFO    = create-note \info   , Chalk.stripColor
const ERROR   = create-note \error  , Chalk.red
const SUCCESS = create-note \success, Chalk.green

module.exports =
  alert: (e, opts)    -> send ERROR, e, (sticky:true) <<< opts
  err  : (e, opts)    -> send ERROR, e, opts
  ok   : (text, opts) -> send SUCCESS, text, opts
  say  : (text, opts) -> send INFO, text, opts

if enabled = (growl-at = process.env.growl-at)?
  log "growl at #growl-at"
  client = new Gntp.Client! <<< host:growl-at
  client.on \response, -> register! if it.type is '-ERROR'
  client.on \error, -> log "growl.error: [#{it.parseInfo.error.code}] #{it.parseInfo.error.text}"
  register!
else log "growl disabled"

## helpers

function create-note name, chalk
  new Gntp.Notification! <<< name:name, displayName:"#APPNAME #name", chalk:chalk

function register
  req = (new Gntp.Application APPNAME).toRequest!
  for note in [INFO, ERROR, SUCCESS] then req.addNotification note
  client.sendMessage req.toRequest!

function send note, text, opts = {}
  if text instanceof Error then text .= message
  Util.log note.chalk text unless opts.nolog
  return unless enabled
  req = note.toRequest! <<< (applicationName:APPNAME, text:text) <<< opts
  client.sendMessage req.toRequest!
