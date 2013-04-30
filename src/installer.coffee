{spawn} = require 'child_process'
{EventEmitter} = require 'events'
{useLoggerForProcess} = require './log-provider'

class Installer extends EventEmitter
  constructor: (@dir, @logger) ->

  # will be called with the callback(err) if err is given, an error occured
  install: (commands, callback) ->
    @processCommand commands, (err) =>
      throw err if err
      
      @emit 'installed'
      callback() if callback
    
  processCommand: (commands, endCallback) ->
    args = commands.shift()
    cmd = args.shift()
    console.log("Execute: (" + cmd + ") " + args.join(' ') + " @(" + @dir + ")")
    process = spawn cmd, args, cwd: @dir
    useLoggerForProcess process, @logger
    process.on 'close', (code) =>
      if code == 0
        if commands.length == 0
          endCallback undefined
        else
          @processCommand commands, endCallback
      else
        endCallback 'Command ' + cmd + ' failed with exit code ' + code

exports.Installer = Installer
