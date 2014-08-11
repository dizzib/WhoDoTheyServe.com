B = require \./_browser
R = require \../helper .run

module.exports =
  github:
    info: 'openauth github'
    fn  : R ->
      log \github
      B.go \user/signin
      # TODO: figure out why the following line blasts the _browser remote window variables
      B.click 'Login with your Github account'
      B.assert.ok!
      B.wait-for \Welcome!, \.main>.show>legend
