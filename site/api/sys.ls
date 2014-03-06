Package = require \../package.json

exports.get = (req, res, next) ->
  res.json do
    version: Package.version
