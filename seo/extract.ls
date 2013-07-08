# external casperjs (non-node) script to extract SEO'ified site
# NOTE: insufficient RAM may cause phantomjs segment fault

C = require \casper .create logLevel:\error verbose:true
F = require \fs

const CLI-KEY-URL-ROOT = \url-root
const ROUTE-HOME = '#/home'

throw new Error '--url-root is required' unless C.cli.has CLI-KEY-URL-ROOT

done    = [ ]
pending = [ ROUTE-HOME ]

C.start!
C.on \remote.message, -> @echo it
C.then -> iterate!
C.run!

function iterate then
  C.echo pending.length
  return C.exit! if pending.length is 0
  visit pending.shift!, iterate

function visit route, cb then
  done.push route
  C.echo "visit #{route}"
  C.thenOpen get-url route
  C.then -> @waitUntilVisible '.view'
  C.then ->
    C.evaluate eval-remove-features
    queue-links!
    C.evaluate eval-seoify-links
    prepare-app! if route is ROUTE-HOME
    save-html-to-file @getHTML!, route
    cb!

function eval-remove-features then $ 'a.btn, a.hide, .meta, .seo-remove' .remove!

function eval-get-links then Array::map.call $(\a), -> it.getAttribute \href

function eval-insert-link-css then
  $ \body .before "<link type='text/css' rel='stylesheet' href='/lib-3p/bootstrap/css/bootstrap.css'>"

function eval-insert-noscript-warning then
  $ \noscript .remove!
  $ \body .before "<div class='alert alert-warning'><noscript>
      You are currently viewing the cut-down version of this site. 
      To view the feature-rich version, please ensure javascript 
      is enabled in your browser before refreshing the page.
    </noscript></div>"

function eval-insert-script-redirect then
  $ \script .remove!
  $ \body .before "<script type='text/javascript'>
      window.location.href = '/#' + window.location.pathname.replace('.html', '');
    </script>"

function eval-seoify-links then
  $ "a[href^='#']" .each -> @href = "#{@hash.replace('#', '')}.html"

function get-url route then "#{C.cli.get CLI-KEY-URL-ROOT}/#{route}"

function maybe-add-pending-link link then
  return unless /^#/.test link
  return if done.indexOf(link) > -1
  return if pending.indexOf(link) > -1
  C.echo "push #{link}"
  pending.push link

function prepare-app then
  C.evaluate eval-insert-link-css
  C.evaluate eval-insert-script-redirect
  C.evaluate eval-insert-noscript-warning

function queue-links then
  for link in C.evaluate eval-get-links
    maybe-add-pending-link link

function save-html-to-file html, route then
  fname = "#{route.replace('#/', '')}.html"
  F.write fname, html
