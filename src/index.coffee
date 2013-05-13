{Api} = require './api'
{Service} = require './service'
{ProcessManager} = require './process-manager'
{Proxy} = require './proxy'
winston = require 'winston'

exports.boot = (port, appDbPath, appPath, logFile) ->
  global.log = new winston.Logger
    transports: [
      new winston.transports.File(filename: logFile),
      new winston.transports.Console(colorize: true, timestamp: true)
    ]
  
  service = new Service appDbPath, appPath, () ->
    api = new Api()
    proxy = new Proxy()
    processManager = new ProcessManager()
  
    # setup the api to use the *service* and *processManager*
    api.setService(service)
    api.setProcessManager(processManager)
  
    # configure the process manager to use the proxy to register and unregister
    # applications
    processManager.setProxy(proxy)
  
    # start the api and make it listen on some port.
    proxy.registerApp(api.name(), api)
  
    # start all applications
    service.allApplications (app) ->
      log.info "start app: " + app.name(),
        app: app.name()
      processManager.redeploy app
  
    # start the porxy itself
    proxy.listen(port)
