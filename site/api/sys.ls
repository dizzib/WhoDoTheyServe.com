Cp = require \child_process
Os = require \os
Pj = require \../package.json

const MODE-MAINT  = \maintenance
const MODE-NORMAL = \normal

mode = MODE-NORMAL
nodejs = version: process.version.replace \v ''
npm = version: Cp.execSync 'npm --version' .toString!replace Os.EOL, ''
os =
  architecture: Os.arch!
  platform    : Os.platform!
  release     : Os.release!
  type        : Os.type!

module.exports =
  get-is-mode-maintenance: -> mode is MODE-MAINT

  read: (req, res, next) ->
    res.json do
      env    : process.env.NODE_ENV
      mode   : mode
      nodejs : nodejs
      npm    : npm
      os     : os
      version: Pj.version

  toggle-mode: (req, res, next) ->
    mode := if mode is MODE-NORMAL then MODE-MAINT else MODE-NORMAL
    res.json mode:mode
