_ = require \underscore
H = require \./helper

exports.get-spec = (...args) ->
  h = H \node, ...args

  a: _.extend do
    h.get-spec \a, name:'Node a'
    name: _.extend do
      h.get-spec \a, name:'Node aa'
      dash  : h.get-spec \a, name:'foo-bar-baz'
      dup   : h.get-spec \a, name:'Node AA'
      max   : h.get-spec \a, name:\x * 50
      max-gt: h.get-spec \a, name:\x * 51
      min   : h.get-spec \a, name:\x * 4
      min-lt: h.get-spec \a, name:\x * 3
      paren :
        open: h.get-spec \a, name:'foo((('
      space :
        end  : h.get-spec \a, name:'foo '
        start: h.get-spec \a, name:' foo'
        multi: h.get-spec \a, name:'  multi   spaced  '
      the   :
        start: h.get-spec \a, name:'The Band of England'
        has  : h.get-spec \a, name:'Bank of England, The'
      dcms  : h.get-spec \a, name:'Department for Culture, Media & Sport'
      you   : h.get-spec \a, name:'YOU! (UK)'
  b: h.get-spec \b, name:'Node b'
  c: h.get-spec \c, name:'Node c'
  d: h.get-spec \d, name:'Node d'
  e: h.get-spec \e, name:'Node e'
  f: h.get-spec \f, name:'Node f'
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2
    is3: h.get-spec-list 3
    is4: h.get-spec-list 4
    is5: h.get-spec-list 5
