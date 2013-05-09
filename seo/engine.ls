Z = require \zombie
S = require \../server

log = console.log

z = new Z #debug: true

exports
  ..init = (server) ->
    server.get /\.html$/, handler

    function handler req, res, next then
      err <- z.visit get-app-url(req), element:\#view.ready
      return next err if err
      cripple-tabmenu!
      seoify-links!
      strip-scripts!
      res.send z.html!

    function get-app-url req then
      log req-port = if S.settings.env isnt \production # heroku port isn't 80
        and (port = process.env.PORT) then ":#{port}" else ''
      log app-path = "##{req.path}".replace \.html, ''
      log app-url = "#{req.protocol}://#{req.host}#{req-port}/#{app-path}"
      app-url

    function strip-scripts then
      z.evaluate "$('script').remove();"

    function seoify-links then
      z.evaluate "
        $('a[href]').each(function() {
          this.href=this.href.replace('\.html', '');
          this.href=this.href.replace('/#', '');
          this.href=this.href + '.html';
          this.href=this.href.replace('/.html', '/index.html');
        });
      "

    function cripple-tabmenu then
      z.evaluate "
        $('li[active=\"^graph\"]').remove();
        $('li[active=\"^user/signin\"]').remove();
      "
