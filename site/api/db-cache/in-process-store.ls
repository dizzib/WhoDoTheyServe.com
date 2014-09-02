# DANGER! Using in a multi-process cloud may result in stale data being served

M = require \mongoose
_ = require \lodash

exports.create = -> new Store!

class Store
  -> @reset!

  clear: (coll-name, key-raw) ->
    #log 'CLEAR'
    if coll-name
      assert-coll-name coll-name
      return null unless _.has @_store, coll-name
      if key-raw then return delete @_store[coll-name][get-key key-raw]
      return delete @_store[coll-name]
    @reset!

  get: (coll-name, key-raw) ->
    #log 'GET', coll-name, key-raw
    assert-coll-name coll-name
    if _.has @_store, coll-name
      coll-store = @_store[coll-name]
      key = get-key key-raw
      if _.has coll-store, key
        @hit-count++
        return @_store[coll-name][get-key key-raw]
    @miss-count++
    null

  set: (coll-name, key-raw, value) ->
    #log 'SET', coll-name, key-raw, value
    assert-coll-name coll-name
    @_store[coll-name] = {} unless _.has @_store, coll-name
    @_store[coll-name][get-key key-raw] = value

  reset: ->
    @_store     = {}
    @hit-count  = 0
    @miss-count = 0

  function assert-coll-name coll-name
    if not _.isString coll-name or coll-name.length > 10
      throw new Error "invalid coll-name #{coll-name}"

  function get-key key-raw
    key = switch
      case _.isString key-raw then key-raw
      case _.isObject key-raw then JSON.parse key-raw
      default then throw new Error "invalid key #{key-raw}"
    if key.length > 32 then throw new Error "key is too long #{key}"
    key
