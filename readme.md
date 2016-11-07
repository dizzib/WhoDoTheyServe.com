# build and run locally &nbsp;[![Build Status][badge-travis-svg]][badge-travis-url]

## install global dependencies

* [node.js][nodejs] >= v4.6.2

* [bcrypt dependencies][bcrypt-deps] (just the dependencies!)

* [mongodb][mongodb] >= v3.2 (run with [`mongod`][mongod])

* [firefox][firefox] running locally for the app integration tests.
Must be a recent version with [marionette][marionette-js].

## git clone, build and run

    $ git clone --branch=dev https://github.com/dizzib/WhoDoTheyServe.com.git
    $ cd WhoDoTheyServe.com
    $ npm install           # install dependencies
    $ npm test              # build site and run tests
    $ npm run-script task   # start the developer task runner

The dev site should now be running at `http://localhost:4000`

Navigate to `http://localhost:4000/#/user/signup` to create an admin user who
should then be able to signup further users.

## notes

The build tasks rely on Linux shell commands such as `pkill` and `rsync` so are unlikely to run on other OS's without some tweaks.

[badge-travis-svg]: https://travis-ci.org/dizzib/WhoDoTheyServe.com.svg?branch=dev
[badge-travis-url]: https://travis-ci.org/dizzib/WhoDoTheyServe.com
[bcrypt-deps]: https://github.com/ncb000gt/node.bcrypt.js#dependencies
[firefox]: https://www.mozilla.org/en-US/firefox/new/
[marionette-js]: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette
[mongod]: http://docs.mongodb.org/manual/reference/program/mongod/
[mongodb]: http://docs.mongodb.org/manual/installation/
[nodejs]: http://nodejs.org/download/
[wdts]: http://www.whodotheyserve.com
