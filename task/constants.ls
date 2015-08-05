Assert = require \assert
Path   = require \path
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
dist = Path.normalize "#root/../wdts-dist"

dir =
  BUILD: "#root/#{DIRNAME.BUILD}"
  build:
    DEV: "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}"
    dev:
      SITE : "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.SITE}"
      TASK : "#root/#{DIRNAME.BUILD}/#{DIRNAME.DEV}/#{DIRNAME.TASK}"
  dist:
    SEO    : "#dist/#{DIRNAME.SEO}"
    STAGING: "#dist/#{DIRNAME.STAGING}"
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
