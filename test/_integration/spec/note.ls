_ = require \underscore
S = require \../state

exports.get-spec = (create, read, update, remove, list) ->
  return
    a : _.extend do
      get-spec \a, text:'The quick brown fox'
      list:
        is0: get-spec-list \a, 0
        is1: get-spec-list \a, 1
        is2: get-spec-list \a, 2
      text:
        min   : get-spec \a, text:\x * 10
        min-lt: get-spec \a, text:\x * 9
        max   : get-spec \a, text:\x * 100
        max-gt: get-spec \a, text:\x * 101
    ab: get-spec \ab
    ac: get-spec \ac
    b : _.extend do
      get-spec \b, text:'Jumps over the lazy dog'
      text:
        min: get-spec \b, text:\x * 10
      list:
        is0: get-spec-list \b, 0
        is1: get-spec-list \b, 1
        is2: get-spec-list \b, 2
    bc: get-spec \bc, text:'them thar hills'
    c : get-spec \c , text:'the music box'

  function get-spec name, fields then
    _.extend do
      get-spec-tests create, name, fields
      get-spec-tests read  , name, fields
      get-spec-tests remove, name, fields
      get-spec-tests update, name, fields

  function get-spec-list name, n then
    info: "note list for #{name} is #{n}"
    fn  : (done) -> list done, name, n

  function get-spec-tests op, name, fields then
    "#{op.name}":
      ok : get-spec-test op, name, true , fields
      bad: get-spec-test op, name, false, fields

  function get-spec-test op, name, is-ok, fields then
    info: "#{op.name} note #{name} #{JSON.stringify(fields) ? ''}
           #{if is-ok then '' else ' bad'}"
    fn  : (done) -> op done, name, is-ok, fields
