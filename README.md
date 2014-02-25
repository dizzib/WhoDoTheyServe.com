Source code for [WhoDoTheyServe.com][wdts]

# To build and run locally

* [install bcrypt dependencies][bcrypt-deps]

* [install mongodb][mongodb] then run with [`mongod`][mongod]

* [install LiveScipt][LiveScript]

* clone the [repository][wdts-repo] from GitHub

The build tasks are written in LiveScript so run this command to compile them into javascript and install the node modules from npm:

* `task/bootstrap`

Now you should be able to launch the task runner:

* `node _build/dev/task/repl`

After a few seconds you should see the help list of commands. Enter the following command to build all files and run the tests:

* `b.fc`

If all goes well you'll find the dev site running at `http://localhost:4000`.

Navigate to `http://localhost:4000/#user/signup` to create an admin user who should then be able to signup further users.

# Notes

The APP integration tests will fail until [this issue][mjs-81] is fixed (I'm currently using a locally patched [marionette-js]).

Also the build tasks rely on Linux shell exec commands such as `pkill` and `rsync` so are unlikely to run on other OS's without some tweaks.


[bcrypt-deps]: https://github.com/ncb000gt/node.bcrypt.js#dependencies
[LiveScript]: http://livescript.net/#installation
[marionette-js]: https://github.com/mozilla-b2g/marionette-js-client
[mjs-81]: https://github.com/mozilla-b2g/marionette-js-client/issues/81
[mongod]: http://docs.mongodb.org/manual/reference/program/mongod/
[mongodb]: http://docs.mongodb.org/manual/installation/
[wdts]: http://www.whodotheyserve.com
[wdts-repo]: https://github.com/dizzib/WhoDoTheyServe.com
