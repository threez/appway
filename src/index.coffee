{Api} = require './api'
{Service} = require './service'
{ProcessManager} = require './process-manager'
{Proxy} = require './proxy'

exports.boot = (port, appDbPath, appPath) ->
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
      console.log("start app: " + app.name())
      processManager.redeploy app
  
    # start the porxy itself
    proxy.listen(port)
