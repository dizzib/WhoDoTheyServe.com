Source code for [WhoDoTheyServe.com][wdts]

# To build and run locally

## Install global dependencies

* [node.js][nodejs]

* [bcrypt dependencies][bcrypt-deps]

* [mongodb][mongodb] (run with [`mongod`][mongod])

* [LiveScript][LiveScript]

## Clone and build

* clone the [repository][wdts-repo] from GitHub

The build tasks are written in LiveScript so issue the following command to make them runnable:

* `task/bootstrap`

Now launch the task runner:

* `node _build/dev/task/repl`

After a few seconds a helpful list of commands should appear. Enter the following command to build all files and run the tests:

* `b.fc`

If all goes well you'll find the dev site running at `http://localhost:4000`.

Navigate to `http://localhost:4000/#/user/signup` to create an admin user who should then be able to signup further users.

# Notes

The APP integration tests will fail until [this issue][mjs-81] is fixed (I'm currently using a locally patched [marionette-js]).

Also the build tasks rely on Linux shell commands such as `pkill` and `rsync` so are unlikely to run on other OS's without some tweaks.


[bcrypt-deps]: https://github.com/ncb000gt/node.bcrypt.js#dependencies
[LiveScript]: http://livescript.net/#installation
[marionette-js]: https://github.com/mozilla-b2g/marionette-js-client
[mjs-81]: https://github.com/mozilla-b2g/marionette-js-client/issues/81
[mongod]: http://docs.mongodb.org/manual/reference/program/mongod/
[mongodb]: http://docs.mongodb.org/manual/installation/
[nodejs]: http://nodejs.org/download/
[wdts]: http://www.whodotheyserve.com
[wdts-repo]: https://github.com/dizzib/WhoDoTheyServe.com
