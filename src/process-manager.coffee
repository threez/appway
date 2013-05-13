{Procfile} = require './procfile'
{Process} = require './process'
path = require 'path'

# General deployment process:
# 1. If a process is running, stop the process, there can be multiple processes
#    per application. The ports the applications are hosting will be unassigned
#    before stopping the applciation server. So they are not proxyed any longer.
# 2. Deploy the application by starting the app.deploy() command. The deploy()
#    will cause the git to install / update the packages installed, update the
#    git repository and execute the install commands.
# 3. After the application was deployed the application will started. This means
#    all depending processes are started based on the Procfile. Every process
#    gets a port assigned by the evironment variable. The port is assigned by
#    the app process manager. the app manager trys to assign ports starting
#    from the basePort.
# 4. The choosen Port will be advertised to the ProxyServer.
#
# Sidenotes:
# * The PORT environment variable is only set to processes that are 
# Question:
# * How to make sure that a worker or background task dosn't get a port and
#   therefore exposed to the outside word
# * How to address different processes inside a application?
#
class ProcessManager
  constructor: () ->
    @processes = {}

  # Setter to configure the proxy that should be used to host the application.
  setProxy: (@proxy) ->

  # Deploy the passed application and call the callback after the application
  # was deployed.
  # @param [Application] app
  # @param [Function] callback
  redeploy: (app, callback) ->
    if processes = @processes[app.name()]
      @stop app, () =>
        @deploy app, callback
    else
      @deploy app, callback

  # Deploy the passed application and call the callback. It starts the app after
  # @param [Application] app
  # @param [Function] callback
  deploy: (app, callback) ->
    app.deploy () =>
      @start app, () =>
        callback() if callback

  start: (app, callback) ->
    @processes[app.name()] ||= {}
    
    procfile = new Procfile(path.join(app.dir(), 'Procfile'))
    procfile.parse (err, config) =>
      for category, cmd of config
        for scale in [0..1]
          ((scale) =>
            processName = "#{category}.#{scale}"
          
            process = new Process(app, processName, cmd)
            log.info "Start app #{process.name()}",
              app: app.name()
            log.debug "Execute",
              cmd: cmd,
              app: app.name()
        
            # start the process depending on the type, web will be treated as
            # web application server, the rest will not have a port.
            if category == 'web'
              process.on 'exit', () =>
                @proxy.unregisterApp(app.name(), process)
              @proxy.registerApp(app.name(), process)
            else
              process.start()
        
            @processes[app.name()][processName] = process
          )(scale)
      
      # return if all processes where started
      callback() if callback

  stop: (app, callback) ->
    processList = @processes[app.name()]
    processCount = Object.keys(processList).length
    
    for name, process of processList
      log.info "Stop app #{process.name()}",
        app: app.name()
      process.stop () =>
        processCount -= 1
        
        # nothing more to stop
        if processCount == 0
          delete @processes[app.name()]    
          callback() if callback

exports.ProcessManager = ProcessManager
