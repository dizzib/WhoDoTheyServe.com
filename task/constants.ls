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

root = pwd!

dir =
  BUILD: "#root/#{DIRNAME.BUILD}"
  build:
    DEV: "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}"
    dev:
      SITE : "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.SITE}"
      TASK : "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.TASK}"
    SEO    : "#root/#{DIRNAME.BUILD}/#{DIRNAME.SEO}"
    STAGING: "#root/#{DIRNAME.BUILD}/#{DIRNAME.STAGING}"
  ROOT : root
  SITE : "#root/#{DIRNAME.SITE}"
  TASK : "#root/#{DIRNAME.TASK}"
  TEST : "#root/#{DIRNAME.TEST}"

module.exports =
  APPNAME: \wdts
  dirname: DIRNAME
  dir    : dir

Assert test \-e dir.SITE
Assert test \-e dir.TASK
Assert test \-e dir.TEST
