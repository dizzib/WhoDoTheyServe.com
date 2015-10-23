# https://github.com/dizzib/fireprox helps automate input of evidence urls
B = require \backbone

const STORE-KEY = \fireprox-url

module.exports =
  configure: ->
    return console.error 'localStorage not supported' unless localStorage
    url = prompt 'Fireprox url' localStorage.getItem STORE-KEY
    return if url is null
    if url?length
      localStorage.setItem STORE-KEY, url
    else
      localStorage.removeItem STORE-KEY

  get-browser-url: (cb) ->
    send-request \content.location.href cb

## helpers

function send-request command, cb
  return cb! unless url = localStorage?getItem STORE-KEY
  $.ajax "#{url}/#{command}",
    error: (coll, xhr) ->
      B.trigger \error xhr?responseText
      cb!
    success: ->
      cb /^\"?(.*)\"$/.exec(it)?1
