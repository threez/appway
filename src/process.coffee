{Monitor} = require 'forever-monitor'
{EventEmitter} = require 'events'

class Process extends EventEmitter
  constructor: (@app, @category, command) ->
    @env = {}
    # LANG, HOME, LOGNAME, USER, 
    for key in ['SHELL', 'TMPDIR', 'PATH']
      @env[key] = process.env[key]
    @user = "www-data"
    @group = "www-data"
    @command = command.split(/\s+/)
    @command.unshift 'env'
  
  name: () ->
    "#{@app.name()}[#{@category}]"

  # 4. Run (execute procfile)
  start: (callback) ->
    @child = new Monitor @command,
      max: 10
      env: @env
      cwd: @app.dir()
      spawnWith:
        setuid: @user
        setgid: @group
        stdio: ['ignore', 'pipe', 'pipe']
  
    @child.on 'exit', (data) =>
      log.debug "Process exited with code: #{1}", @metadata
      @emit 'exit', @
    
    @child.on 'error', (data) =>
      log.error data.toString(), @metadata

    @child.on 'start', (process) =>
      @metadata =
        port: @port
        pid: process.child.pid
        app: @name()
      
      process.child.on 'data', (data) =>
        log.info data.toString(), @metadata

      process.child.stdout.on 'data', (data) =>
        log.info data.toString(), @metadata

      process.child.stderr.on 'data', (data) =>
        log.error data.toString(), @metadata
        
      log.debug "Process started", @metadata
      
      @emit 'started', @child
      callback(@child) if callback
    
    @child.start()

  stop: (callback) ->
    @child.stop()
    @emit 'stopped'
    log.debug "Stop process", @metadata
    callback() if callback

  listen: (port, host) ->
    @env['PORT'] = @port = port
    @env['HOST'] = @host = host
    @start()

exports.Process = Process
