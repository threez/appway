{EventEmitter} = require 'events'
{spawn} = require 'child_process'
fs = require 'fs'

class Repository extends EventEmitter
  constructor: (@config) ->
    @url = @config.url
    @branch = @config.branch
    @dir = @config.dir
    @git_path = @dir + '/.git'
    
    @on 'pulled', => @emit 'synced'
    @on 'cloned', => @emit 'synced'
    
  sync: ->
    fs.exists @git_path, (exists) =>
      if exists
        @pull()
      else
        @clone()
    
  pull: ->
    process = spawn 'env', @pullArgs(),
      cwd: @dir
    # TODO: add output of cloning to install log
    # process.stdout.on 'data', (data) ->
    #   console.log 'stdout: ' + data
    # 
    # process.stderr.on 'data', (data) ->
    #   console.log 'stderr: ' + data
    
    process.on 'close', (code) =>
      if code == 0
        @emit 'pulled'
      else
        @emit 'error', code
    
  clone: ->
    process = spawn 'env', @cloneArgs()
    
    # TODO: add output of cloning to install log
    # process.stdout.on 'data', (data) ->
    #   console.log 'stdout: ' + data
    # 
    # process.stderr.on 'data', (data) ->
    #   console.log 'stderr: ' + data
    
    process.on 'close', (code) =>
      if code == 0
        @emit 'cloned'
      else
        @emit 'error', code
  
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
