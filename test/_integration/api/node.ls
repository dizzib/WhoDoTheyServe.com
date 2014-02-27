C = require \./_crud
S = require \../spec/node

c = C \nodes
module.exports = S.get-spec c.create, c.read, c.update, c.remove, c.list
