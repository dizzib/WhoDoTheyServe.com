C = require \./_crud
S = require \../spec/note

c = C \notes
module.exports = S.get-spec c.create-for, c.read, c.update, c.remove, c.list-for
