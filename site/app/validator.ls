B = require \backbone
H = require \./helper

export init = ->
  invalid-orig = B.Validation.callbacks.invalid
  B.Validation.callbacks.invalid = ->
    invalid-orig ...
    H.show-error '''
      One or more fields have errors.
      Please correct them before retrying.
      '''
