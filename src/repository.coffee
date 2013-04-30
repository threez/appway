{EventEmitter} = require 'events'
{spawn} = require 'child_process'
{useLoggerForProcess} = require './log-provider'
fs = require 'fs'
path = require 'path'

class Repository extends EventEmitter
  constructor: (@config, @logger) ->
    @url = @config.url
    @branch = @config.branch
    @dir = @config.dir
    @git_path = @dir + '/.git'
    
    @on 'pulled', => @emit 'synced'
    @on 'cloned', => @emit 'synced'
    
  sync: (callback) ->
    fs.exists @git_path, (exists) =>
      if exists
        @pull callback
      else
        @clone callback
    
  pull: (callback) ->
    process = spawn 'env', @pullArgs(), cwd: @dir
    useLoggerForProcess process, @logger
    
    process.on 'close', (code) =>
      if code == 0
        @emit 'pulled'
        callback(undefined, this) if callback
      else
        @emit 'error', code
        callback('unable to pull', this) if callback
    
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
  
  pullArgs: ->
    args = ['git', 'pull']
  
  cloneArgs: ->
    args = ['git', 'clone']
    if @branch
      args.push '-b'
      args.push @branch
    args.push '--'
    args.push @url
    args.push @dir
    args

exports.Repository = Repository
