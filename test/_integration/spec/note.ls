_ = require \underscore
H = require \./helper

exports.get-spec = (...args) ->
  h = H \note, ...args

  a: _.extend do
    h.get-spec \a, text:'The quick brown fox'
    list:
      is0: h.get-spec-list 0, \a
      is1: h.get-spec-list 1, \a
      is2: h.get-spec-list 2, \a
    text:
      min   : h.get-spec \a, text:\x * 10
      min-lt: h.get-spec \a, text:\x * 9
      max   : h.get-spec \a, text:\x * 200
      max-gt: h.get-spec \a, text:\x * 201
      jotld : h.get-spec \a, text:'Jumps over the lazy dog'
  ab: h.get-spec \ab
  ac: h.get-spec \ac
  b: _.extend do
    h.get-spec \b, text:'Jumps over the lazy dog'
    text:
      tqbf: h.get-spec \b, text:'The quick brown fox'
      min : h.get-spec \b, text:\x * 10
    list:
      is0: h.get-spec-list 0, \b
      is1: h.get-spec-list 1, \b
      is2: h.get-spec-list 2, \b
  bc: h.get-spec \bc, text:'them thar hills'
  c : h.get-spec \c , text:'the music box'
