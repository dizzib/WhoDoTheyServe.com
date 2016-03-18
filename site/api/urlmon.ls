_     = require \lodash
R     = require \request
M-Evs = require \./model/evidences

period-days = process.env.URLMON_PERIOD_DAYS

module.exports =
  start: ->
    return log 'urlmon is disabled' unless period-days > 0
    ulog "starting to check each evidence url every #period-days day(s)"
    err, evs <- M-Evs.find!lean!exec
    return ulog err if err
    check-next _.take evs, 10

function check ev
  function fail msg
    log msg
  function log msg
    ulog "#{ev.url} #msg"
  try
    r = R url = ev.url, { strictSSL:false timeout:20000ms }, (err, res) ->
      return fail err if err
    r.on \response (res) ->
      r.abort!
      sc = res.statusCode
      # for some reason, cpexposed.com returns 402 (payment required) even though it's ok
      if sc in [200 402] then log "is ok" else fail "response code = #sc"
  catch e
    fail e

function check-next evs
    return unless ev = evs.pop!
    check ev
    ulog "#{evs.length} remaining"
    _.delay (-> check-next evs), 10000ms

function ulog msg then console.log 'urlmon:' msg
