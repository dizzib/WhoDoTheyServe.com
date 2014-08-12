H  = require \./helper
Pj = require \../package.json

const MODE-MAINT  = \maintenance
const MODE-NORMAL = \normal

mode = MODE-NORMAL

module.exports =
  get-is-mode-maintenance: -> mode is MODE-MAINT

  read: (req, res, next) -> res.json { mode:mode, version:Pj.version }

  toggle-mode: (req, res, next) ->
    mode := if mode is MODE-NORMAL then MODE-MAINT else MODE-NORMAL
    res.json mode:mode
