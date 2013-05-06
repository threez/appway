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
        
    @child.on 'exit', () =>
      @emit 'exit', @
      
    @child.on 'error', (data) =>
      console.log(data)
      
    @child.start()
    
    @emit 'started', @chil
    callback(@child) if callback

  stop: (callback) ->
    @child.stop()
    @emit 'stopped'
    callback() if callback

  listen: (port, host) ->
    @env['PORT'] = @port = port
    @env['HOST'] = @host = host
    @start()

exports.Process = Process
