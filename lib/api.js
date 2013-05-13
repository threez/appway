(function() {
  var Api, ProcessManager, Service, express, send;

  Service = require('./service').Service;

  ProcessManager = require('./process-manager').ProcessManager;

  express = require('express');

  send = require('send');

  Api = (function() {

    function Api() {
      var _this = this;
      this.app = express();
      this.app.use(express.logger('dev'));
      this.app.use(express.bodyParser());
      this.app.get('/applications', function(req, res) {
        return _this.service.list(function(list) {
          return res.json(list);
        });
      });
      this.app.post('/applications', function(req, res) {
        return _this.service.create(req.body, function(app) {
          if (app) {
            return _this.processManager.redeploy(app, function(result) {
              return res.send(200);
            });
          } else {
            return res.send(409, {
              error: 'Conflict, the applications already exists'
            });
          }
        });
      });
      this.app.get('/applications/:name', function(req, res) {
        return _this.service.findManifest(req.params.name, function(manifest) {
          if (manifest) {
            return res.json(manifest);
          } else {
            return res.send(404, {
              error: 'The application is not defined'
            });
          }
        });
      });
      this.app.put('/applications/:name', function(req, res) {
        return _this.service.update(req.params.name, req.body, function(app) {
          if (app) {
            return _this.processManager.redeploy(app, function(result) {
              return res.send(200);
            });
          } else {
            return res.send(404, {
              error: 'The application is not defined'
            });
          }
        });
      });
      this.app.del('/applications/:name', function(req, res) {
        return _this.service.destroy(req.params.name, function(result) {
          if (result) {
            return res.send(200);
          } else {
            return res.send(404, {
              error: 'The application is not defined'
            });
          }
        });
      });
      this.app.get('/applications/:name/logs/:log', function(req, res) {
        return _this.findApplication(req, res, function(app) {
          return send(req, app.log(req.params.log)).pipe(res);
        });
      });
      this.app.post('/applications/:name/start', function(req, res) {
        return _this.findApplication(req, res, function(app) {
          return _this.processManager.start(app, function(result) {
            return res.send(200);
          });
        });
      });
      this.app.post('/applications/:name/restart', function(req, res) {
        return _this.findApplication(req, res, function(app) {
          return _this.processManager.restart(app, function(result) {
            return res.send(200);
          });
        });
      });
      this.app.post('/applications/:name/stop', function(req, res) {
        return _this.findApplication(req, res, function(app) {
          return _this.processManager.stop(app, function(result) {
            return res.send(200);
          });
        });
      });
      this.app.post('/applications/:name/redeploy', function(req, res) {
        return _this.findApplication(req, res, function(app) {
          return _this.processManager.redeploy(app, function(result) {
            return res.send(200);
          });
        });
      });
    }

    Api.prototype.findApplication = function(req, res, callback) {
      var _this = this;
      return this.service.findApplication(req.params.name, function(app) {
        if (app) {
          return callback(app);
        } else {
          return res.send(404, {
            error: 'The application is not defined'
          });
        }
      });
    };

    Api.prototype.name = function() {
      return "appway";
    };

    Api.prototype.setService = function(service) {
      this.service = service;
    };

    Api.prototype.setProcessManager = function(processManager) {
      this.processManager = processManager;
    };

    Api.prototype.listen = function(port, host) {
      return this.app.listen(port, host);
    };

    return Api;

  })();

  exports.Api = Api;

}).call(this);
