_  = require \lodash
W  = require \wait.for
H  = require \./_http
ST = require \../state

module.exports = (entity-name) ->

  ## functions are named for logging
  return
    create: function create then
      submit-create ...

    create-for: function create key, is-ok, fields then
      parent = get-node-or-edge key
      entity = entity_id:parent._id
      submit-create key, is-ok, _.extend entity, fields

    read: function read key, is-ok, fields then
      throw new Error 'require > 0 fields to assert' unless fields
      H.assert (res = H.get get-route key), is-ok
      for k, v of fields then res.object[k].should.equal v

    update: function update key, is-ok, fields then
      entity = _id:ST[entity-name][key]._id
      H.assert (res = H.put get-route(key), _.extend entity, fields), is-ok
      if H.is-ok res then ST[entity-name][entity.key] = res.body

    remove: function remove key, is-ok then
      H.assert (res = H.del get-route key), is-ok
      if H.is-ok res then delete ST[entity-name][key]

    list: function list n, key then
      H.list get-route(key), n

    list-for: function list n, key then
      route = "#{entity-name}/for/#{get-node-or-edge key ._id}"
      H.list route, n

  ## helpers

  function submit-create key, is-ok, fields then
    H.assert (res = H.post get-route!, fields), is-ok
    if H.is-ok res then (ST[entity-name] ?= {})[key] = res.body

  function get-node-or-edge key then
    # key can take form parent:id e.g. 'ab:2' is entity 2 on edge ab
    key = key.split ':' .0 if key.indexOf(':') > 0
    if key.length is 1 then ST.nodes[key] else ST.edges[key]

  function get-route key then
    return "#{entity-name}/#{ST[entity-name][key]._id}" if key
    entity-name
