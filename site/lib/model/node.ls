module.exports =
  is-person: ->
    /^([A-Z]\w+\s)*[A-Z]\w+, [A-Z]\w+(\s\(?\w+\)?)*$/.test it
      and not /(, The(\s|$))/.test it
