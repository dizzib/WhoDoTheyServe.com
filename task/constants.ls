Assert = require \assert
Shell  = require \shelljs/global

const build   = \_build
const dev     = \dev
const site    = \site
const staging = \staging
const seo     = \seo

const dir-root         = pwd!
const dir-build        = "#dir-root/#build"
const dir-dev          = "#dir-build/#dev"
const dir-site-dev     = "#dir-dev/#site"
const dir-site-staging = "#dir-build/#staging"
const dir-site-seo     = "#dir-build/#seo"

module.exports = M =
  dirname:
    BUILD  : build
    DEV    : dev
    SITE   : site
    STAGING: staging
    SEO    : seo
  dir:
    ROOT : dir-root
    BUILD: dir-build
    DEV  : dir-dev
    site :
      DEV    : dir-site-dev
      STAGING: dir-site-staging
      SEO    : dir-site-seo

Assert /\/wdts$/.test M.dir.ROOT
