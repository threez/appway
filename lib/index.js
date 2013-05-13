(function() {
  var Api, ProcessManager, Proxy, Service, winston;

  Api = require('./api').Api;

  Service = require('./service').Service;

  ProcessManager = require('./process-manager').ProcessManager;

  Proxy = require('./proxy').Proxy;

  winston = require('winston');

  exports.boot = function(port, appDbPath, appPath, logFile) {
    var service;
    global.log = new winston.Logger({
      transports: [
        new winston.transports.File({
          filename: logFile
        }), new winston.transports.Console({
          colorize: true,
          timestamp: true
        })
      ]
    });
    return service = new Service(appDbPath, appPath, function() {
      var api, processManager, proxy;
      api = new Api();
      proxy = new Proxy();
      processManager = new ProcessManager();
      api.setService(service);
      api.setProcessManager(processManager);
      processManager.setProxy(proxy);
      proxy.registerApp(api.name(), api);
      service.allApplications(function(app) {
        log.info("start app: " + app.name(), {
          app: app.name()
        });
        return processManager.redeploy(app);
      });
      return proxy.listen(port);
    });
  };

}).call(this);
