C = require \./_crud
S = require \../spec/evidence

c = C \evidences
module.exports = S.get-spec c.create-for, c.read, void, c.remove, c.list-for
