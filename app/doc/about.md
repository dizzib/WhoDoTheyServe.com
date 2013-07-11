### About

WhoDoTheyServe.com is a non-profit [opensource] effort to track and
visualise the rapidly changing global political, banking and corporate power
structure. A secondary purpose is to highlight possible [conflict of interest][coi].

As far as possible, actors and connections are backed up with reliable evidence
to keep this site grounded in fact and not speculation or conspiracy theory.

This site is experimental and open to new ideas/suggestions which
you can add to [github issues][issues].

If you'd like to suggest new actors or connections then please email
them to me via the contact link in the page footer,
and don't forget to include url(s) of reliable evidence!

### API

The data is freely available in [JSON] format via an [API]:
[nodes](http://wdts.eu01.aws.af.cm/api/nodes)
[edges](http://wdts.eu01.aws.af.cm/api/edges)
[evidences](http://wdts.eu01.aws.af.cm/api/evidences)
[users](http://wdts.eu01.aws.af.cm/api/users)

### Credits

Many thanks to the authors of the opensource software used to make this site:

arch-linux
backbone
backbone-deep-model
backbone-routefilter
backbone-validation
bcrypt
brfs
browserify
casperjs
chai
crypto
d3
express
git
glyphicons
guard
icomoon
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

Also thanks to [GitHub], [MongoLab] and [AppFog] for their free hosting.

### Privacy

This site does not use 3rd party tracking tools like Google analytics.
The only information captured is
[visitor count](http://wdts.eu01.aws.af.cm/api/hive/n-hits-2013).

### Security

Contributor passwords are hashed using [bcrypt] before storing in the
database so should be safe even if the database gets hacked.

Contributor email addresses are encrypted using [256-bit aes][aes]
and never disclosed. Even so, it's probably wise to
use a [disposable email address][disp-email].


[appfog]:     http://appfog.com
[aes]:        http://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[api]:        http://en.wikipedia.org/wiki/Application_programming_interface
[bcrypt]:     https://github.com/ncb000gt/node.bcrypt.js
[beta]:       https://en.wikipedia.org/wiki/Software_release_life_cycle
[coi]:        http://en.wikipedia.org/wiki/Conflict_of_interest
[disp-email]: http://en.wikipedia.org/wiki/Disposable_e-mail_address
[github]:     https://github.com
[issues]:     https://github.com/dizzib/WhoDoTheyServe.com/issues
[json]:       http://en.wikipedia.org/wiki/Json
[mongolab]:   http://mongolab.com
[opensource]: https://github.com/dizzib/WhoDoTheyServe.com
