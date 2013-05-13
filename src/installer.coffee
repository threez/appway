{spawn} = require 'child_process'
{EventEmitter} = require 'events'
{useLoggerForProcess} = require './log-provider'

class Installer extends EventEmitter
  constructor: (@dir) ->

  # will be called with the callback(err) if err is given, an error occured
  install: (commands, callback) ->
    @processCommand commands, (err) =>
      throw err if err
      
      @emit 'installed'
      callback() if callback
    
  processCommand: (commands, endCallback) ->
    args = commands.shift()
    cmd = args.shift()
    log.info "Execute: (" + cmd + ") " + args.join(' ') + " @(" + @dir + ")"
    process = spawn cmd, args, cwd: @dir
    useLoggerForProcess process, @logger
    process.on 'close', (code) =>
      if code == 0
        if commands.length == 0
          endCallback undefined
        else
          @processCommand commands, endCallback
      else
        msg = "Command #{cmd} failed with exit code #{code}"
        log.error msg
        endCallback msg

exports.Installer = Installer
