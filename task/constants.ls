Assert = require \assert
Shell  = require \shelljs/global

const BUILD   = \_build
const DEV     = \dev
const SITE    = \site
const STAGING = \staging
const SEO     = \seo

const DIR-ROOT         = pwd!
const DIR-BUILD        = "#DIR-ROOT/#BUILD"
const DIR-DEV          = "#DIR-BUILD/#DEV"
const DIR-SITE-DEV     = "#DIR-DEV/#SITE"
const DIR-SITE-STAGING = "#DIR-BUILD/#STAGING"
const DIR-SITE-SEO     = "#DIR-BUILD/#SEO"

module.exports = M =
  dirname:
    BUILD  : BUILD
    DEV    : DEV
    SITE   : SITE
    STAGING: STAGING
    SEO    : SEO
  dir:
    ROOT : DIR-ROOT
    BUILD: DIR-BUILD
    DEV  : DIR-DEV
    site :
      DEV    : DIR-SITE-DEV
      STAGING: DIR-SITE-STAGING
      SEO    : DIR-SITE-SEO

Assert test \-e "#DIR-ROOT/#SITE"
Assert test \-e "#DIR-ROOT/task"
Assert test \-e "#DIR-ROOT/test"
