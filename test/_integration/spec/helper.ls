_ = require \lodash
U = require \util
H = require \../helper

module.exports = (entity-name, create, read, update, remove, list) ->

  get-spec: (key, fields) ->
    function get-spec-tests op, key, fields
      return {} unless op?
      "#{op.name}":
        ok : get-spec-test op, true , key, fields
        bad: get-spec-test op, false, key, fields

    function get-spec-test op, is-ok, key, fields
      info: "#{op.name} #{if is-ok then '' else 'bad '}
             #{entity-name} #{key ? ''} #{JSON.stringify(fields) ? ''}"
      fn  : H.run -> op key, is-ok, fields

    _.extend do
      get-spec-tests create, key, fields
      get-spec-tests read  , key, fields
      get-spec-tests update, key, fields
      get-spec-tests remove, key, fields

  get-spec-list: (n, key) ->
    info: "#{entity-name} list is #{n}#{if key then ' for ' + key else ''}"
    fn  : H.run ~> list n, key
