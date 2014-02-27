# fireprox helps automate input of evidence urls
# https://github.com/dizzib/fireprox

H = require \./helper

const STORE-KEY = \fireprox-url

exports
  ..setup-url = ->
    return H.log 'localStorage not supported' unless localStorage
    url = prompt 'Fireprox url', localStorage.getItem STORE-KEY
    return if url is null
    if url?length then
      localStorage.setItem STORE-KEY, url
    else
      localStorage.removeItem STORE-KEY

  ..send-request = (command, cb) ->
    return cb! unless url = localStorage?getItem STORE-KEY
    $.ajax "#{url}/exec/#{command}",
      error: ->
        H.log ...
        cb!
      success: ->
        cb /^\"?(.*)\"$/.exec(it)?1
