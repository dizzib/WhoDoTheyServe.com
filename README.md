Source code for [WhoDoTheyServe.com][wdts]

# build and run locally

## install global dependencies

* [node.js][nodejs] v0.10

* [bcrypt dependencies][bcrypt-deps] (just the dependencies!)

* [mongodb][mongodb] (run with [`mongod`][mongod])

* [livescript][livescript] to build the task runner during bootstrap

* [firefox][firefox] running locally for the app integration tests.
Must be a recent version with [marionette][marionette-js].

## clone and bootstrap project

    $ git clone git@github.com:dizzib/WhoDoTheyServe.com.git
    $ ./task/bootstrap          # compile task runner and install npm dependencies

## build and run site

    $ node _build/dev/task/repl # launch the task runner (ignore any dev/staging site errors)
    wdts > b.all                # compile everything, run tests, and launch site

The dev site should now be running at `http://localhost:4000`

Navigate to `http://localhost:4000/#/user/signup` to create an admin user who
should then be able to signup further users.

## notes

The build tasks rely on Linux shell commands such as `pkill` and `rsync` so are unlikely to run on other OS's without some tweaks.

[bcrypt-deps]: https://github.com/ncb000gt/node.bcrypt.js#dependencies
[firefox]: https://www.mozilla.org/en-US/firefox/new/
[livescript]: http://livescript.net/#installation
[marionette-js]: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette
[mongod]: http://docs.mongodb.org/manual/reference/program/mongod/
[mongodb]: http://docs.mongodb.org/manual/installation/
[nodejs]: http://nodejs.org/download/
[wdts]: http://www.whodotheyserve.com
