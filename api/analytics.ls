_    = require \underscore
H    = require \./helper
Hive = require \./hive
D    = require \./lib/date

exports
  ..measure = (req, res, next) ->
    unless req.session.counted
      req.session.counted = true
      _.delay inc-n-hits , 1000ms
      _.delay log-referer, 2000ms
    return next!

    function inc-n-hits then
      value = Hive.get key = "n-hits-#{yyyy = D.get-current-year!}"
      n-hits = if value then JSON.parse value else []
      w = D.get-current-deciweek-of-year!
      n-hits[w] = 1 + (n-hits[w] or 0)
      err <- Hive.set key, JSON.stringify n-hits
      H.log "inc-n-hits failed: #{err}" if err

    function log-referer then
      return unless r = req.get \referer
      value = Hive.get const KEY = \referers
      rs = if value then JSON.parse value else []
      return if r is rs.0 # ignore duplicate
      rs.unshift r
      rs = _.first rs, 20items
      err <- Hive.set KEY, JSON.stringify rs
      H.log "log-referer failed: #{err}" if err
