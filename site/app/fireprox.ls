# fireprox helps automate input of evidence urls
# https://github.com/dizzib/fireprox

const STORE-KEY = \fireprox-url

exports
  ..setup-url = ->
    return console.error 'localStorage not supported' unless localStorage
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
        console.error ...
        cb!
      success: ->
        cb /^\"?(.*)\"$/.exec(it)?1
