### About

WhoDoTheyServe.com is a non-profit [opensource] effort to visualise the
global political, financial and corporate power structure.
A secondary purpose is to highlight possible
[conflict of interest][coi].

Actors and connections are backed up with evidence from reputable and official
sources in an attempt to keep this site grounded in fact and not speculation
or conspiracy theory.

This site is experimental and open to new ideas/suggestions which
you can add to [github issues][issues].

### Data

The data is freely available in [JSON] format via an [API]:
[nodes](http://wdts10.eu01.aws.af.cm/api/nodes)
[edges](http://wdts10.eu01.aws.af.cm/api/edges)
[evidences](http://wdts10.eu01.aws.af.cm/api/evidences)
[users](http://wdts10.eu01.aws.af.cm/api/users)

A [production database dump][db-dump] is maintained in github.

### Security

Contributor passwords are hashed using [bcrypt] before storing in the
database, so are irretrievable.

Contributor email addresses are encrypted using [256-bit aes][aes]
and never revealed.
Even so, you might want to use a [disposable email address][disp-email].

### Privacy

This site does not use 3rd party tracking tools like Google analytics.
The only information captured is
[visitor count per 10-days](http://wdts10.eu01.aws.af.cm/api/hive/n-hits-2013).

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
chai
crypto
d3
express
git
glyphicons
icomoon
jade
jquery
livescript
lodash
marionette
mocha
mongodb
mongoose
node.js
request
shortid
stylus
timeago
transparency
twitter-bootstrap
underscore
yepnope

Also thanks to [GitHub], [MongoLab] and [AppFog] for their free hosting.


[appfog]:     http://appfog.com
[aes]:        http://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[api]:        http://en.wikipedia.org/wiki/Application_programming_interface
[bcrypt]:     https://github.com/ncb000gt/node.bcrypt.js
[beta]:       https://en.wikipedia.org/wiki/Software_release_life_cycle
[coi]:        http://en.wikipedia.org/wiki/Conflict_of_interest
[db-dump]:    https://github.com/dizzib/prod-db-dump 
[disp-email]: http://en.wikipedia.org/wiki/Disposable_e-mail_address
[github]:     https://github.com
[graph]:      #/graph
[issues]:     https://github.com/dizzib/WhoDoTheyServe.com/issues
[json]:       http://en.wikipedia.org/wiki/Json
[mongolab]:   http://mongolab.com
[opensource]: https://github.com/dizzib/WhoDoTheyServe.com
