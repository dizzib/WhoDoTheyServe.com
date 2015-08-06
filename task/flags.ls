Em = require \events .EventEmitter
Sh = require \shelljs/global

const DEFAULT =
  site:
    logging: false
  test:
    autorun: true
    coverage: false
    run:
      api: true
      app: true
const STORE = "#__dirname/flags.json"

cache = load!

module.exports = (new Em!) with do
  get: -> cache
  toggle: ->
    path = it.split \.
    c = path[til -1].reduce ((o, k) -> o[k]), cache
    k = path[*-1]
    c[k] = not (c[k] or false)
    save!
    @emit \toggle

function load
  try
    return JSON.parse(cat STORE) if test \-e STORE
    DEFAULT
  catch
    DEFAULT

function save then (JSON.stringify cache).to STORE
