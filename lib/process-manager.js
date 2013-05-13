(function() {
  var Process, ProcessManager, Procfile, path;

  Procfile = require('./procfile').Procfile;

  Process = require('./process').Process;

  path = require('path');

  ProcessManager = (function() {

    function ProcessManager() {
      this.processes = {};
    }

    ProcessManager.prototype.setProxy = function(proxy) {
      this.proxy = proxy;
    };

    ProcessManager.prototype.redeploy = function(app, callback) {
      var processes;
      var _this = this;
      if (processes = this.processes[app.name()]) {
        return this.stop(app, function() {
          return _this.deploy(app, callback);
        });
      } else {
        return this.deploy(app, callback);
      }
    };

    ProcessManager.prototype.deploy = function(app, callback) {
      var _this = this;
      return app.deploy(function() {
        return _this.start(app, function() {
          if (callback) return callback();
        });
      });
    };

    ProcessManager.prototype.start = function(app, callback) {
      var procfile, _base, _name;
      var _this = this;
      (_base = this.processes)[_name = app.name()] || (_base[_name] = {});
      procfile = new Procfile(path.join(app.dir(), 'Procfile'));
      return procfile.parse(function(err, config) {
        var category, cmd, scale, _fn;
        for (category in config) {
          cmd = config[category];
          _fn = function(scale) {
            var process, processName;
            processName = "" + category + "." + scale;
            process = new Process(app, processName, cmd);
            log.info("Start app " + (process.name()), {
              app: app.name()
            });
            log.debug("Execute", {
              cmd: cmd,
              app: app.name()
            });
            if (category === 'web') {
              process.on('exit', function() {
                return _this.proxy.unregisterApp(app.name(), process);
              });
              _this.proxy.registerApp(app.name(), process);
            } else {
              process.start();
            }
            return _this.processes[app.name()][processName] = process;
          };
          for (scale = 0; scale <= 1; scale++) {
            _fn(scale);
          }
        }
        if (callback) return callback();
      });
    };

    ProcessManager.prototype.stop = function(app, callback) {
      var name, process, processCount, processList, _results;
      var _this = this;
      processList = this.processes[app.name()];
      processCount = Object.keys(processList).length;
      _results = [];
      for (name in processList) {
        process = processList[name];
        log.info("Stop app " + (process.name()), {
          app: app.name()
        });
        _results.push(process.stop(function() {
          processCount -= 1;
          if (processCount === 0) {
            delete _this.processes[app.name()];
            if (callback) return callback();
          }
        }));
      }
      return _results;
    };

    return ProcessManager;

  })();

  exports.ProcessManager = ProcessManager;

}).call(this);
