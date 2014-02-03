E = require \./entity
S = require \../spec/node

e = E \nodes
module.exports = S.get-spec e.create, e.read, e.update, e.remove, e.list
