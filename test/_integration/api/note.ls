E = require \./entity
S = require \../spec/note

e = E \notes
module.exports = S.get-spec e.create-for, e.read, e.update, e.remove, e.list-for
