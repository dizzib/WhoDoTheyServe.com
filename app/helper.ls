exports
  ..log = -> console.log.apply console, arguments

  ..on-err = (coll, xhr) ->
    const MSG = 'An error occurred (check the debug console for more details)'
    $ \.alert-error .text get-friendly(xhr.responseText) || MSG .show!

function get-friendly msg then
  msg
    .replace 'edge'  , 'connection'
    .replace 'Edge'  , 'Connection'
    .replace 'node'  , 'actor'
    .replace 'Node'  , 'Actor'
    .replace 'an con', 'a con'
    .replace 'a act' , 'an act'
