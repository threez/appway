(function() {
  var Proxy, httpProxy;

  httpProxy = require('http-proxy');

  Proxy = (function() {

    function Proxy(startPort) {
      var _this = this;
      this.localhost = '127.0.0.1';
      this.global = '0.0.0.0';
      this.startPort = startPort || 5000;
      this.maxPorts = 1000;
      this.endPort = this.startPort + this.maxPorts;
      this.ports = {};
      this.apps = {};
      this.appHeader = "x-app";
      this.loadBalancer = {};
      this.defaultAppName = 'default';
      this.server = httpProxy.createServer(function(req, res, proxy) {
        var appName;
        if (appName = req.headers[_this.appHeader]) {
          return _this.proxyToApp(proxy, req, res, appName);
        } else if (_this.apps[_this.defaultAppName] != null) {
          return _this.proxyToApp(proxy, req, res, _this.defaultAppName);
        } else {
          return _this.clientError(res, "Error: Need to pass the 'X-App' Header");
        }
      });
    }

    Proxy.prototype.proxyToApp = function(proxy, req, res, appName) {
      var port;
      if (port = this.portForApp(appName)) {
        return proxy.proxyRequest(req, res, {
          host: this.localhost,
          port: port
        });
      } else {
        return this.clientError(res, "Error: app '" + appName + "' don't exist!");
      }
    };

    Proxy.prototype.portForApp = function(appName) {
      var port, ports;
      if (ports = this.apps[appName]) {
        this.loadBalancer[appName] += 1;
        port = ports[this.loadBalancer[appName] % ports.length];
        return port;
      }
    };

    Proxy.prototype.registerApp = function(name, app) {
      var port;
      port = this.registerPort(name, app);
      app.listen(port, this.localhost);
      return log.info("Started app '" + (app.name()) + "' on " + this.localhost + ":" + port, {
        app: app.name()
      });
    };

    Proxy.prototype.registerPort = function(name, app) {
      var port, _base, _base2, _ref, _ref2;
      for (port = _ref = this.startPort, _ref2 = this.endPort; _ref <= _ref2 ? port <= _ref2 : port >= _ref2; _ref <= _ref2 ? port++ : port--) {
        if (!this.ports[port]) {
          this.ports[port] = app;
          (_base = this.apps)[name] || (_base[name] = []);
          this.apps[name].push(port);
          (_base2 = this.loadBalancer)[name] || (_base2[name] = 0);
          return port;
        }
      }
    };

    Proxy.prototype.unregisterApp = function(name, app) {
      var index, process;
      process = this.ports[app.port];
      delete this.ports[app.port];
      index = this.apps[name].indexOf(app.port);
      this.apps[name] = this.apps[name].slice(0, index).concat(this.apps[name].slice(index + 1, this.apps[name].length));
      log.info("Removed app '" + (app.name()) + "' from " + this.localhost + ":" + app.port, {
        app: app.name()
      });
      if (this.apps[name].length === 0) {
        delete this.apps[name];
        delete this.loadBalancer[name];
        return log.info("Removed app " + name + " completely", {
          app: app.name()
        });
      }
    };

    Proxy.prototype.listen = function(port) {
      this.server.listen(port, this.global);
      return log.info("Started proxy on " + this.global + ":" + port);
    };

    Proxy.prototype.clientError = function(res, errorText) {
      res.writeHead(400, {
        'Content-Type': 'text/plain'
      });
      return res.end("" + errorText + "\n");
    };

    return Proxy;

  })();

  exports.Proxy = Proxy;

}).call(this);
