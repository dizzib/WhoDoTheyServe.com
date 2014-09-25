Assert = require \assert
Shell  = require \shelljs/global

const DIRNAME =
  BUILD  : \_build
  DEV    : \dev
  SITE   : \site
  STAGING: \staging
  SEO    : \seo
  TASK   : \task
  TEST   : \test

dir-root = pwd!
dir =
  BUILD: "#dir-root/#{DIRNAME.BUILD}"
  build:
    DEV: "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}"
    dev:
      SITE : "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.SITE}"
    SEO    : "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.SEO}"
    STAGING: "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.STAGING}"
  ROOT : dir-root
  SITE : "#dir-root/#{DIRNAME.SITE}"
  site : # deprecate
    DEV    : "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.SITE}"
    SEO    : "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.SEO}"
    STAGING: "#dir-root/#{DIRNAME.BUILD}/#{DIRNAME.STAGING}"
  TASK : "#dir-root/#{DIRNAME.TASK}"
  TEST : "#dir-root/#{DIRNAME.TEST}"

log module.exports =
  dirname: DIRNAME
  dir    : dir

Assert test \-e dir.SITE
Assert test \-e dir.TASK
Assert test \-e dir.TEST
