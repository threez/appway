{EventEmitter} = require 'events'
{Repository} = require './repository'
{Installer} = require './installer'
{Procfile} = require './procfile'
{spawn} = require 'child_process'
winston = require 'winston'
path = require 'path'

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
    if packages = @manifest.packages["apt-get"]
      cmds = [
        ['apt-get', 'update'],
        ['apt-get', 'install', '-y', packages.join(' ')]
      ]
      installer = new Installer(undefined, @logger('install'))
      installer.install cmds, (err) =>
        throw err if err
        @emit 'packages-installed'
        callback() if callback
    else
      @logger('install').warn 'Skipped install of packages!'
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
    cmds = []
    @manifest.install.forEach (cmd) ->
      cmds.push cmd.split(/\s+/)

    installer = new Installer(@manifest.repo.dir, @logger('install'))
    installer.install cmds, (err) =>
      throw err if err
      @emit 'installed'
      callback() if callback

  # 4. Run (execute procfile)
  start: (callback) ->
    console.log("ConfigProcfile...")
    procfile = new Procfile(path.join(@manifest.repo.dir, 'Procfile'))
    procfile.parse (config) ->
      console.log(config)
    
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
