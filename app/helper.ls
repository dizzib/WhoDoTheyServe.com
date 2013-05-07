exports
  ..log = -> console.log.apply console, arguments

  ..on-err = (, xhr) ->
    msg = get-friendly(xhr.responseText) || 'An error occurred. Sorry!'
    $ \.alert-error .text msg .show!

function get-friendly msg then
  msg
    .replace 'edge'  , 'connection'
    .replace 'Edge'  , 'Connection'
    .replace 'node'  , 'actor'
    .replace 'Node'  , 'Actor'
    .replace 'an con', 'a con'
    .replace 'a act' , 'an act'
