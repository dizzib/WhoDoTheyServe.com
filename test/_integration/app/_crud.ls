SH = require \chai .should!
_  = require \underscore
B  = require \./_browser
ST = require \../state

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
    on-create     : ->
    on-remove     : -> opts.wait-for-list!
    on-update     : ->
    wait-for-list : -> B.wait-for new RegExp(opts.coll-ui!), \legend
    opts

  return
    create: function create key, is-ok, fields then
      opts.go-create ...
      opts.fill fields, key
      submit \Create, opts.on-create, ...&

    update: function update key, is-ok, fields then
      opts.go-maintain ...
      opts.fill fields, key
      submit \Update, opts.on-update, ...&

    remove: function remove key, is-ok then
      opts.go-maintain ...
      B.arrange.confirm true
      submit \Delete, opts.on-remove, ...&

    list: function list n-expect, key then
      opts.go-list key
      n-actual = B.wait-for sel:".#{opts.coll-name!}>ul>li", require-unique:false
      n-actual.should.equal n-expect

## private helpers

  function submit action, on-success, key, is-ok, fields
    B.click action
    B.assert.ok is-ok
    on-success key, fields if is-ok

  function capitalise then
    it.0.toUpperCase! + it.slice 1

  function go-create key then
    opts.go-list key
    B.click \New

  function go-maintain key then
    opts.go-list key
    opts.go-entity key
    opts.go-edit key

  function go-edit key then
    B.click \Edit, \legend>a
    B.wait-for new RegExp("Edit #{opts.ent-ui!}"), \legend
