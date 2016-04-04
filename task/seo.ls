Assert  = require \assert
_       = require \lodash
Cheerio = require \cheerio
Mc      = require \marionette-client
Os      = require \os
Path    = require \path
Shell   = require \shelljs/global
W4      = require \wait.for .for
W4m     = require \wait.for .forMethod
Cfg     = require \./config
Dist    = require \./constants .dir.dist
G       = require \./growl

module.exports =
  # Due to the dynamic nature of the site, we'll render each page in
  # Firefox then manipulate it using cheerio
  generate: (env-id) ->
    try
      const BROWSER-HOST   = process.env.firefox-host or \localhost
      const EXCLUDE-ROUTES = /map/
      const ROUTE-HOME     = '#/nodes'
      const SITE-URL       = "http://#{Os.hostname!}:#{Cfg[env-id].primary.PORT}"

      log "generate seo from #SITE-URL via firefox at #BROWSER-HOST"

      md = new Mc.Drivers.Tcp host:BROWSER-HOST
      mc = new Mc.Client md
      W4m md, \connect
      W4m mc, \startSession
      W4m mc, \setSearchTimeout 15000

      rm \-rf Dist.SEO if test \-e Dist.SEO
      mkdir Dist.SEO

      done    = [ ]
      pending = [ ROUTE-HOME ]
      start   = Date.now!
      while pending.length
        done.push route = pending.shift!
        log "done=#{done.length - 1} pending=#{pending.length + 1} #route"
        url = "#SITE-URL/#route"
        W4m mc, \executeScript (-> window.location.href = it), [ url ]
        W4 pause, 10ms
        while (W4m mc, \executeScript -> document.querySelectorAll \.rendering .length)
          W4 pause, 100ms
        html = W4m mc, \pageSource
        $ = Cheerio.load html
        amend-css $
        amend-scripts $
        strip-html $
        queue-links pending, done, $
        seoify-links $
        html = $.html!
        save-html-to-file html, route
      mins = (Date.now! - start)/60000
      G.ok "SEO: generated #{done.length} files in #mins minutes" sticky:true
    finally then W4m mc, \deleteSession

    ## helpers

    function amend-css $
      function insert-link href then $ \body .before "<link type='text/css' rel='stylesheet' href='#href'>"
      $ "link[rel='stylesheet']" .remove!
      $ \style .remove!
      insert-link \/lib-3p/bootstrap/css/bootstrap.css
      insert-link \/app.css

    function amend-scripts $
      $ \script .remove!
      $ \noscript .remove!
      $ \.navbar-fixed-bottom .replaceWith "
        <div class='navbar-fixed-bottom'><div class='alert alert-danger navbar-text'>
          You are currently viewing the cut-down version of this site. 
          To view the feature-rich version, please ensure javascript 
          is enabled in your browser before refreshing the page.
        </div></div>"
      $ \body .before "
        <script type='text/javascript'>
          window.location.href = '/#' + window.location.pathname.replace('.html', '');
        </script>"

    function pause ms, cb then setTimeout (-> cb!), ms

    function queue-links pending, done, $
      links = _.map ($ \a), -> $ it .attr \href
      for l in links
        if not _.includes done, l and not _.includes pending, l
        and /^#/.test l and not EXCLUDE-ROUTES.test l
          #log "push #l"
          pending.push l

    function save-html-to-file html, route
      path = "#{Dist.SEO}/#{route.replace('#/', '')}.html"
      dir = Path.dirname path
      mkdir \-p dir unless test \-e dir
      #log "write #{html.length} bytes to #path"
      html.to path

    function seoify-links $
      $ "a[href^='#']" .each ->
        href = ($el = $ this).attr \href
        $el.attr \href "#{href.replace('#', '')}.html"

    function strip-html $
      $ 'a.btn, a.hide, .meta, .seo-remove' .remove!
      $ ".view>*[style='display: none;']" .remove! # :hidden doesn't work
