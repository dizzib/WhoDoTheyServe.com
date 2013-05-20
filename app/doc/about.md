### About
A secondary purpose is to highlight possible [conflict of interest][coi].

As far as possible, actors and connections are backed up with evidence
to keep this site grounded in fact and not speculation (conspiracy theory).

This site is experimental and open to new ideas/suggestions which
you can add to [github issues][issues].

If you'd like to become a contributor then please email me
via the contact link below.

### API

The data is freely available in [JSON] format via an [API]:
[nodes](http://wdts.eu01.aws.af.cm/api/nodes)
[edges](http://wdts.eu01.aws.af.cm/api/edges)
[evidences](http://wdts.eu01.aws.af.cm/api/evidences)
[users](http://wdts.eu01.aws.af.cm/api/users)

### Credits

I'd like to thank the authors of the opensource software used to make this site:

arch-linux
backbone
backbone-deep-model
backbone-routefilter
backbone-validation
bcrypt
brfs
browserify
chai
crypto
d3
express
git
glyphicons
guard
jade
jquery
livescript
mocha
mongodb
mongoose
node
nodemon
request
stylus
timeago
transparency
twitter-bootstrap
underscore
yepnope
zombie

### Privacy

This site does not use tracking tools like google analytics.

### Security

Contributor passwords are hashed using [bcrypt] before storing in the
database so should be safe even if the database gets hacked.

Contributor email addresses are encrypted using [256-bit aes][aes]
and never disclosed. Even so, it's probably wise to
use a [disposable email address][disp-email].

[aes]:       http://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[api]:       http://en.wikipedia.org/wiki/Application_programming_interface
[bcrypt]:    https://github.com/ncb000gt/node.bcrypt.js
[beta]:      https://en.wikipedia.org/wiki/Software_release_life_cycle
[coi]:       http://en.wikipedia.org/wiki/Conflict_of_interest
[disp-email]:http://en.wikipedia.org/wiki/Disposable_e-mail_address
[issues]:    https://github.com/dizzib/WhoDoTheyServe.com/issues
[json]:      http://en.wikipedia.org/wiki/Json
