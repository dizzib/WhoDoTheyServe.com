Z = require \zombie

log = console.log

z = new Z do
  #debug       : true
  waitDuration: 1000ms

exports
  ..init = (server) ->
    server.get /\.html$/, handler

    function handler req, res, next then
      err <- z.visit get-app-url req
      return next err if err
      strip-scripts!
      cripple-tabmenu!
      seoify-links!
      res.send z.html!

    function get-app-url req then
      log req-port = if (port = process.env.PORT) then ":#{port}" else ''
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
        $('li[active=\"^user-signin\"]').remove();
      "
