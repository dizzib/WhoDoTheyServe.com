B  = require \backbone
F  = require \fs # inlined by brfs
Th = require \../theme

module.exports = B.View.extend do
  initialize: ->
    @$el.html F.readFileSync __dirname + \/footer.html
    Th.init!
    B.on \boot ~> @render!

  render: ->
    $el = @$el
    $ \ul.themes>li .on \click -> Th.switch-theme ($ this .data \theme-id)
    $ '.social [data-toggle="dropdown"]' .dropdown!on \toggled -> update-hrefs!

    function update-hrefs
      $el.find \.title .text loc = "http://whodotheyserve.com/#{window.location.hash}"
      loc .= replace \# \%23
      $el.find \.email .attr \href "mailto:?subject=Check out this site&body=#loc"
      $el.find \.facebook .attr \href "http://www.facebook.com/sharer/sharer.php?u=#loc"
      $el.find \.twitter .attr \href "https://twitter.com/intent/tweet?url=#loc"
      $el.find \.gplus .attr \href "https://plusone.google.com/_/+1/confirm?hl=en&url=#loc"
