_ = require \underscore
H = require \./helper
S = require \../state

exports.get-spec = (c, r, u, d, list) ->
  h = new H \note, c, r, u, d, list
  return
    a : _.extend do
      h.get-spec \a, text:'The quick brown fox'
      list:
        is0: h.get-spec-list 0, \a
        is1: h.get-spec-list 1, \a
        is2: h.get-spec-list 2, \a
      text:
        min   : h.get-spec \a, text:\x * 10
        min-lt: h.get-spec \a, text:\x * 9
        max   : h.get-spec \a, text:\x * 100
        max-gt: h.get-spec \a, text:\x * 101
    ab: h.get-spec \ab
    ac: h.get-spec \ac
    b : _.extend do
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
