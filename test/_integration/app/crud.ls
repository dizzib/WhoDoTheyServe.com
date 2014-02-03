_  = require \underscore
F  = require \./firedrive
H  = require \./helper
ST = require \../state

module.exports = (ent-name, opts) ->

  # override default opts to customise behaviour
  opts = _.extend do
    coll-name     : -> ent-name + \s                # e.g. nodes
    coll-ui       : -> capitalise opts.ent-ui! + \s # e.g. Actors
    ent-ui        : -> capitalise ent-name          # e.g. Actor
    go-create     : go-create
    go-edit       : go-edit
    go-entity     : -> F.click it, \a
    go-list       : -> F.click opts.coll-ui!, \a
    go-maintain   : go-maintain
    on-create     : ->
    on-remove     : -> opts.wait-for-list!
    on-update     : ->
    wait-for-list : -> F.wait-for new RegExp(opts.coll-ui!), \legend
    opts

  return
    create: function create key, is-ok, fields then
      opts.go-create ...
      opts.fill fields, key
      submit 'Create', opts.on-create, ...&

    update: function update key, is-ok, fields then
      opts.go-maintain ...
      opts.fill fields, key
      submit \Update, opts.on-update, ...&

    remove: function remove key, is-ok then
      opts.go-maintain ...
      F.arrange.confirm true
      submit \Delete, opts.on-remove, ...&

    list: function list n, key then
      opts.go-list key
      F.assert.count n, ".#{opts.coll-name!}>ul>li"

## helpers

  function submit action, on-success, key, is-ok, fields
    F.click action
    H.assert-ok is-ok
    on-success key, fields if is-ok

  function capitalise then
    it.0.toUpperCase! + it.slice 1

  function go-create key then
    opts.go-list key
    F.click \New

  function go-maintain key then
    opts.go-list key
    opts.go-entity key
    opts.go-edit key

  function go-edit key then
    F.click \Edit, \legend>a
    F.wait-for new RegExp("Edit #{opts.ent-ui!}"), \legend
