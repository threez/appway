class Application
  constructor: (@manifest) ->

  # 1. Install the required pakages using `apt-get`on ubuntu
  packages: () ->

  # 2. Clone the git repository (git pull/clone) and start the application
  download: () ->

  # 3. Execute the install commands
  install: () ->

  # 4. Run (execute procfile)
  start: () ->

exports.Application = Application
