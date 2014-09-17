W4m     = require \wait.for .forMethod
M-Edges = require \../api/model/edges

module.exports =
  migrate: ->
    edges = W4m M-Edges, \find, when:undefined
    log "found #{edges.length} edges without when"
    for e in edges
      yf = (e.get \year_from) or ''
      yt = (e.get \year_to) or ''
      w = "#yf-#yt"
      continue if w is \-
      e.set \when, w
      log W4m e, \save

    # http://bites.goodeggs.com/post/36553128854/how-to-remove-a-property-from-a-mongoosejs-schema/
    n = W4m M-Edges.collection,
      \update,
      { },
      $unset: { year_from:true, year_to:true },
      { multi:true, strict:false }
    log "removed fields year_* from #n edges"
