B  = require \backbone
F  = require \fs # inlined by brfs
Th = require \../theme

module.exports = B.View.extend do
  initialize: ->
    @T = F.readFileSync __dirname + \/footer.html
    Th.init!
    B.on \boot ~> @render!
    B.on \routed ->
      hash = window.location.hash.replace \# \%23
      loc = "http://whodotheyserve.com/#hash"
      @$ \.title .text "Share #loc"
      @$ \.email .attr \href "mailto:?subject=Check out this site&body=#loc"
      @$ \.facebook .attr \href "http://www.facebook.com/sharer/sharer.php?u=#loc"
      @$ \.twitter .attr \href "https://twitter.com/intent/tweet?url=#loc"
      @$ \.gplus .attr \href "https://plusone.google.com/_/+1/confirm?hl=en&url=#loc"

  render: ->
    @$el.replaceWith @T .show!
    $ \ul.themes>li .on \click -> Th.switch-theme ($ this .data \theme-id)
