{EventEmitter} = require 'events'
{Repository} = require './repository'
winston = require 'winston'

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
  # Returns the path to the log with the passed name
  # @param [String] context the name might be install, process, error
  log: (context) ->
    @manifest.logs[context]

  # Returns the logger object to use for context to use.
  logger: (context) ->
    if logger = @loggers[context]
      logger
    else
      @loggers[context] = new winston.Logger
        transports: [
          new winston.transports.Console(),
          new winston.transports.File(filename: @log(context))
        ]

exports.Application = Application
