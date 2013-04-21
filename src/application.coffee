{EventEmitter} = require 'events'

class Application extends EventEmitter
  constructor: (@manifest) ->

  # 1. Install the required pakages using `apt-get`on ubuntu
  installPackages: () ->
    @emit 'packages-installed'

  # 2. Clone the git repository (git pull/clone) and start the application
  download: () ->
    @emit 'downloaded'

  # 3. Execute the install commands
  install: () ->
    @emit 'installed'

  # 4. Run (execute procfile)
  start: () ->
    @emit 'started'

  stop: () ->

  log: (name) ->

exports.Application = Application
