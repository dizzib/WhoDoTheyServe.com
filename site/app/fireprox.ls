# fireprox helps automate input of evidence urls
# https://github.com/dizzib/fireprox
H = require \./helper

const STORE-KEY = \fireprox-url

module.exports =
  setup-url: ->
    return console.error 'localStorage not supported' unless localStorage
    url = prompt 'Fireprox url', localStorage.getItem STORE-KEY
    return if url is null
    if url?length then
      localStorage.setItem STORE-KEY, url
    else
      localStorage.removeItem STORE-KEY

  send-request: (command, cb) ->
    return cb! unless url = localStorage?getItem STORE-KEY
    $.ajax "#{url}/#{command}",
      error: ->
        H.on-err ...
        cb!
      success: ->
        cb /^\"?(.*)\"$/.exec(it)?1
