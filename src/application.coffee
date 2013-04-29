{EventEmitter} = require 'events'
{Repository} = require './repository'
winston = require 'winston'

class Application extends EventEmitter
  constructor: (@manifest) ->
    @loggers = {}

  bootstrap: (callback) ->
    @installPackages () =>
      @download () =>
        @install () =>
          @start () =>
            @emit 'bootstraped'
            callback() if callback

  # 1. Install the required pakages using `apt-get`on ubuntu
  installPackages: (callback) ->
    @emit 'packages-installed'
    callback() if callback

  # 2. Clone the git repository (git pull/clone) and start the application
  download: (callback) ->
    repository = new Repository(@manifest.repo, @logger('install'))
    repository.sync (err) =>
      throw err if err
      @emit 'downloaded', @, repository
      callback(@, repository) if callback

  # 3. Execute the install commands
  install: (callback) ->
    @emit 'installed'
    callback() if callback

  # 4. Run (execute procfile)
  start: (callback) ->
    @emit 'started'
    callback() if callback

  stop: (callback) ->
    @emit 'stopped'
    callback() if callback

  # Returns the path to the log with the passed name
  # @param [String] context the name might be install, process, error
  log: (context) ->
    if @manifest.logs?
      @manifest.logs[context]

  # Returns the logger object to use for context to use.
  logger: (context) ->
    if logger = @loggers[context]
      logger
    else
      if @log(context)
        @loggers[context] = new winston.Logger
          transports: [
            new winston.transports.Console(),
            new winston.transports.File(filename: @log(context))
          ]
      else
        @loggers[context] = new winston.Logger
          transports: [ new winston.transports.Console() ]

exports.Application = Application
