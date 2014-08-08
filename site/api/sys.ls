H  = require \./helper
Pj = require \../package.json

const MODE-MAINT  = \maintenance
const MODE-NORMAL = \normal

mode = MODE-NORMAL

module.exports =
  get-is-mode-maintenance: -> mode is MODE-MAINT

  read: (req, res, next) -> res.json { mode:mode, version:Pj.version }

  update: (req, res, next) ->
    mo = (b = req.body).mode
    return next new H.ApiError "unexpected mode #mo" unless mo in [ MODE-MAINT, MODE-NORMAL ]
    mode := mo
    res.json mode:mode
