_ = require \underscore

module.exports = class
  (@entity-name, @create, @read, @update, @remove, @list) ->

  get-spec: (key, fields) -> _.extend do
    @get-spec-tests @create, key, fields
    @get-spec-tests @read  , key, fields
    @get-spec-tests @update, key, fields
    @get-spec-tests @remove, key, fields

  get-spec-list: (n, e-key) ->
    info: "#{@entity-name} list is #{n}#{if e-key then ' for ' + e-key}"
    fn  : (done) ~> @list done, n, e-key

  get-spec-tests: (op, key, fields) ->
    "#{op.name}":
      ok : @get-spec-test op, key, true , fields
      bad: @get-spec-test op, key, false, fields

  get-spec-test: (op, key, is-ok, fields) ->
    info: "#{op.name} #{@entity-name} #{key} #{JSON.stringify(fields) ? ''}
           #{if is-ok then '' else ' bad'}"
    fn  : (done) -> op done, key, is-ok, fields
