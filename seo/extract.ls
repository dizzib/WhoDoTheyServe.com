# casperjs script to extract SEO'ified site

C = require \casper .create logLevel:\error verbose:true
F = require \fs

const CLI-KEY-URL-ROOT = \url-root
throw new Error '--url-root is required' unless C.cli.has CLI-KEY-URL-ROOT
url-root = C.cli.get CLI-KEY-URL-ROOT
done     = []
pending  = []
pending.push '#/home'

C.start!
C.then -> iterate!
C.run!

function iterate then
  C.echo pending.length
  return C.exit! if pending.length is 0
  visit pending.pop!, iterate

function visit route, cb then
  C.thenOpen "#{url-root}/#{route}"
  C.then -> @waitUntilVisible '.view'
  C.then ->
    C.evaluate eval-filter-links
    C.evaluate eval-cripple-tabmenu
    C.evaluate eval-remove-scripts
    queue-links!
    C.evaluate eval-seoify-links
    save-html-to-file @getHTML!, route
    done.push route
    cb!

function eval-cripple-tabmenu then
  $ 'li[active=\"^graph\"]'       .remove!
  $ 'li[active=\"^user/signin\"]' .remove!

function eval-filter-links then
  $ \a.btn  .remove!
  $ \a.hide .remove!

function eval-get-links then
  Array::map.call $(\a), (x) -> x.getAttribute \href

function eval-seoify-links then
  $ "a[href^='#']" .each -> @href = "#{@hash.replace('#', '')}.html"

function eval-remove-scripts then $ \script .remove!

function maybe-add-pending-link link then
  return unless /^#/.test link
  return if done.indexOf(link) > -1
  return if pending.indexOf(link) > -1
  C.echo link
  pending.push link

function queue-links then
  for link in C.evaluate eval-get-links
    maybe-add-pending-link link

function save-html-to-file html, route then
  fname = "#{route.replace('#/', '')}.html"
  F.write fname, html
