B = require \backbone

B.on \pre-route (name) ->
  $ \.alert-error .removeClass \active    # clear any error alert location overrides
  $ \.view>.alert-error .addClass \active # reset back to default

## session
B.on \signed-in-by-user  -> show-alert 'Welcome! You are now logged in'
B.on \signed-out-by-user -> show-alert 'Goodbye! You are now logged out'
B.on \signed-out-by-session-expired -> show-error 'Your session has expired. Please login again to continue.'

## error handling
B.on \error -> show-error it
B.on \validation-error -> show-error "One or more fields have errors. Please correct them before retrying."

## helpers

function show-alert msg then $ \.view>.alert-info .text msg .show!

function show-error
  # The .active class can be used to override the default error alert location
  msg = it or 'An error occurred (check the debug console for more details)'
  $ \.alert-error.active:last .text msg .show!
