_ = require \lodash
H = require \./helper

exports.get-spec = (...args) ->
  h = H \node ...args

  a: _.extend do
    h.get-spec \a name:'Node a'
    name: _.extend do
      h.get-spec \a name:'Node aa'
      dash  : h.get-spec \a name:'Foo-bar-baz'
      dcms  : h.get-spec \a name:'Départment for Culture, Media & Sport'
      max   : h.get-spec \a name:\X * 50
      max-gt: h.get-spec \a name:\X * 51
      min   : h.get-spec \a name:\X * 4
      min-lt: h.get-spec \a name:\X * 3
      paren :
        open: h.get-spec \a name:'Foo((('
      space:
        end  : h.get-spec \a name:'Foo '
        start: h.get-spec \a name:' Foo'
        multi: h.get-spec \a name:'  multi   spaced  '
      the:
        start: h.get-spec \a name:'The Band of England'
        has  : h.get-spec \a name:'Bank of England, The'
      ucase: h.get-spec \a name:'Node AA'
      you  : h.get-spec \a name:'YOU! (UK)'
    tags: _.extend do
      lcase1: h.get-spec \a tags:<[ bank ]>
      lcase2: h.get-spec \a tags:<[ tv music ]>
      min-lt: h.get-spec \a tags:<[ a ]>
      max-gt: h.get-spec \a tags:[ \X * 21 ]
      ucase : h.get-spec \a tags:<[ Tv music ]>
  b: _.extend do
    h.get-spec \b name:'Node b'
    dup: h.get-spec \b name:'Node AA'
  c: h.get-spec \c name:'Node c'
  d: h.get-spec \d name:'Node d'
  e: h.get-spec \e name:'Node e'
  f: h.get-spec \f name:'Node f'
  g: _.extend do
    h.get-spec \g name:'Node g'
    name: _.extend do
      h.get-spec \g name:'Node gg'
  list:
    is0: h.get-spec-list 0
    is1: h.get-spec-list 1
    is2: h.get-spec-list 2
    is3: h.get-spec-list 3
    is4: h.get-spec-list 4
    is5: h.get-spec-list 5
