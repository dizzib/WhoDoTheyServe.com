E = require \./entity
S = require \../spec/evidence

e = E \evidences
module.exports = S.get-spec e.create-for, e.read, void, e.remove, e.list-for
