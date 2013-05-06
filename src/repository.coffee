{EventEmitter} = require 'events'
{spawn} = require 'child_process'
{useLoggerForProcess} = require './log-provider'
fs = require 'fs'
path = require 'path'

class Repository extends EventEmitter
  constructor: (@config, @logger) ->
    @on 'pulled', => @emit 'synced'
    @on 'cloned', => @emit 'synced'
  
  # Sync the repository, syncing will use either pull or clone to download the
  # latest state of the repository.
  # @param [Function] callback if callback is passed, the callback will be
  #   triggered after the repository was synced.
  sync: (callback) ->
    fs.exists path.join(@config.dir, '.git'), (exists) =>
      if exists
        @pull callback
      else
        @clone callback
  
  # Pulls the git repository.
  # @param [Function] callback if callback is passed, the callback will be
  #   triggered after the repository was pulled.
  # @event 'pulled' will be triggered if the repository was pulled.
  # @event 'error' will be triggered if an error (command != 0) happend. The
  #   code (statuscode) of the git command will be passed with the event.
  pull: (callback) ->
    process = spawn 'env', @pullArgs(), cwd: @config.dir
    useLoggerForProcess process, @logger
    
    process.on 'close', (code) =>
      if code == 0
        @emit 'pulled'
        callback(undefined, this) if callback
      else
        @emit 'error', code
        callback('unable to pull', this) if callback
  
  # Clones the git repository.
  # @param [Function] callback if callback is passed, the callback will be
  #   triggered after the repository was cloned.
  # @event 'cloned' will be triggered if the repository was cloned.
  # @event 'error' will be triggered if an error (command != 0) happend. The
  #   code (statuscode) of the git command will be passed with the event.
  clone: (callback) ->
    process = spawn 'env', @cloneArgs()
    useLoggerForProcess process, @logger
    
    process.on 'close', (code) =>
      if code == 0
        @emit 'cloned'
        callback(undefined, this) if callback
      else
        @emit 'error', code
        callback('unable to clone', this) if callback
  
  # Create git pull command
  # @return [Array<String>]
  pullArgs: ->
    args = ['git', 'pull']
  
  # Create git clone command
  # @return [Array<String>]
  cloneArgs: ->
    args = ['git', 'clone']
    if @config.branch
      args.push '-b'
      args.push @config.branch
    args.push '--'
    args.push @config.url
    args.push @config.dir
    args

exports.Repository = Repository
