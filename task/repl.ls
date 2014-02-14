global.log = console.log

Rdln  = require \readline
Build = require \./build
Run   = require \./run

<- Build.init on-built:Run.recycle
<- Run.init

rl = Rdln.createInterface input:process.stdin, output:process.stdout
  ..setPrompt "wdts q/r >"
  ..prompt!
  ..on \line, ->
    switch it
    | \cf =>
      Build.clean-files!
      @prompt!
    | \n =>
      Build.npm-refresh!
      @prompt!
    | \q =>
      Build.stop!
      return rl.close!
    | \r =>
      Build.clean-files!
      Build.compile-all!
      @prompt!
    | _  =>
      @prompt!
Build.start!
Run.recycle!
