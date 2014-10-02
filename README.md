Source code for [WhoDoTheyServe.com][wdts]

# Build and run locally

## Install global dependencies

* [node.js][nodejs] v0.10

* [bcrypt dependencies][bcrypt-deps]

* [mongodb][mongodb] (run with [`mongod`][mongod])

* [livescript][livescript] for building the task runner

* [firefox][firefox] running locally for the app integration tests.
Must be a recent version with [marionette][marionette-js].

## Clone and build

    $ git clone git@github.com:dizzib/WhoDoTheyServe.com.git

    $ ./task/bootstrap          # compile task runner and install dependencies
    $ node _build/dev/task/repl # launch the task runner
    wdts > b.fc                 # compile all files

The dev site should now be running at `http://localhost:4000`

Navigate to `http://localhost:4000/#/user/signup` to create an admin user who
should then be able to signup further users.

# Notes

The build tasks rely on Linux shell commands such as `pkill` and `rsync` so are unlikely to run on other OS's without some tweaks.

[bcrypt-deps]: https://github.com/ncb000gt/node.bcrypt.js#dependencies
[firefox]: https://www.mozilla.org/en-US/firefox/new/
[livescript]: http://livescript.net/#installation
[marionette-js]: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette
[mongod]: http://docs.mongodb.org/manual/reference/program/mongod/
[mongodb]: http://docs.mongodb.org/manual/installation/
[nodejs]: http://nodejs.org/download/
[wdts]: http://www.whodotheyserve.com
