SH = require \chai .should!
_  = require \underscore
B  = require \./_browser

module.exports = (ent-name, opts) ->

  # override default opts to customise behaviour
  opts = _.extend do
    coll-name     : -> ent-name + \s                # e.g. nodes
    coll-ui       : -> capitalise opts.ent-ui! + \s # e.g. Actors
    ent-ui        : -> capitalise ent-name          # e.g. Actor
    go-create     : go-create
    go-edit       : go-edit
    go-entity     : -> B.click it, \a
    go-list       : -> B.click opts.coll-ui!, \a
    go-maintain   : go-maintain
    on-create     : -> wait-for-entity it
    on-remove     : -> wait-for-list!
    on-update     : -> wait-for-entity it
    opts

  return
    create: function create key, is-ok, fields
      opts.go-create ...
      opts.fill fields, key
      submit \Create, opts.on-create, ...&

    update: function update key, is-ok, fields
      opts.go-maintain ...
      opts.fill fields, key
      submit \Update, opts.on-update, ...&

    remove: function remove key, is-ok
      opts.go-maintain ...
      B.arrange.confirm true
      submit \Delete, opts.on-remove, ...&

    list: function list n-expect, key
      go-list key
      B.assert.count n-expect, sel:".#{opts.coll-name!}>ul>li"

## private helpers

  function submit action, on-success, key, is-ok, fields
    B.click action
    B.assert.ok is-ok
    on-success key, fields if is-ok

  function capitalise
    it.0.toUpperCase! + it.slice 1

  function go-create key
    go-list key
    B.click \New

  function go-list key
    opts.go-list key
    wait-for-list!

  function go-maintain key
    go-list key
    opts.go-entity key
    opts.go-edit key

  function go-edit key
    B.click \Edit, \legend>a
    B.wait-for-visible (new RegExp "Edit #{opts.ent-ui!}"), \legend

  function wait-for-entity key
    B.wait-for-visible (new RegExp key), \h2

  function wait-for-list
    B.wait-for-visible (new RegExp opts.coll-ui!), \legend
    #B.wait-for-visible class:opts.coll-name!
