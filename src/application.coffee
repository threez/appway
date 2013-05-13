{EventEmitter} = require 'events'
{Repository} = require './repository'
{Installer} = require './installer'
{Procfile} = require './procfile'
{spawn} = require 'child_process'
path = require 'path'

class Application extends EventEmitter
  constructor: (@manifest) ->
  
  name: () ->
    @manifest.name
    
  dir: () ->
    @manifest.repo.dir
    
  deploy: (callback) ->
    @installPackages () =>
      @download () =>
        @install () =>
          @emit 'deployed'
          callback() if callback

  # 1. Install the required pakages using `apt-get` on ubuntu
  installPackages: (callback) ->
    if packages = @manifest.packages["apt-get"]
      cmds = [
        ['apt-get', 'update'],
        ['apt-get', 'install', '-y', packages.join(' ')]
      ]
      installer = new Installer(undefined, log, @)
      installer.install cmds, (err) =>
        throw err if err
        @emit 'packages-installed'
        callback() if callback
    else
      log.warn 'Skipped install of packages!',
        app: @.name()
      @emit 'packages-installed'
      callback() if callback

  # 2. Clone the git repository (git pull/clone) and start the application
  download: (callback) ->
    repository = new Repository(@manifest.repo, log, @)
    repository.sync (err) =>
      throw err if err
      @emit 'downloaded', @, repository
      callback(@, repository) if callback

  # 3. Execute the install commands
  install: (callback) ->
    cmds = []
    @manifest.install.forEach (cmd) ->
      cmds.push cmd.split(/\s+/)

    installer = new Installer(@manifest.repo.dir, log, @)
    installer.install cmds, (err) =>
      throw err if err
      @emit 'installed'
      callback() if callback

exports.Application = Application
