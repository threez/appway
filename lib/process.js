(function() {
  var EventEmitter, Monitor, Process;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Monitor = require('forever-monitor').Monitor;

  EventEmitter = require('events').EventEmitter;

  Process = (function() {

    __extends(Process, EventEmitter);

    function Process(app, category, command) {
      var key, _i, _len, _ref;
      this.app = app;
      this.category = category;
      this.env = {};
      _ref = ['SHELL', 'TMPDIR', 'PATH'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        this.env[key] = process.env[key];
      }
      this.user = "www-data";
      this.group = "www-data";
      this.command = command.split(/\s+/);
      this.command.unshift('env');
    }

    Process.prototype.name = function() {
      return "" + (this.app.name()) + "[" + this.category + "]";
    };

    Process.prototype.start = function(callback) {
      var _this = this;
      this.child = new Monitor(this.command, {
        max: 10,
        env: this.env,
        cwd: this.app.dir(),
        spawnWith: {
          setuid: this.user,
          setgid: this.group,
          stdio: ['ignore', 'pipe', 'pipe']
        }
      });
      this.child.on('exit', function(data) {
        log.debug("Process exited with code: " + 1, _this.metadata);
        return _this.emit('exit', _this);
      });
      this.child.on('error', function(data) {
        return log.error(data.toString(), _this.metadata);
      });
      this.child.on('start', function(process) {
        _this.metadata = {
          port: _this.port,
          pid: process.child.pid,
          app: _this.name()
        };
        process.child.on('data', function(data) {
          return log.info(data.toString(), _this.metadata);
        });
        process.child.stdout.on('data', function(data) {
          return log.info(data.toString(), _this.metadata);
        });
        process.child.stderr.on('data', function(data) {
          return log.error(data.toString(), _this.metadata);
        });
        log.debug("Process started", _this.metadata);
        _this.emit('started', _this.child);
        if (callback) return callback(_this.child);
      });
      return this.child.start();
    };

    Process.prototype.stop = function(callback) {
      this.child.stop();
      this.emit('stopped');
      log.debug("Stop process", this.metadata);
      if (callback) return callback();
    };

    Process.prototype.listen = function(port, host) {
      this.env['PORT'] = this.port = port;
      this.env['HOST'] = this.host = host;
      return this.start();
    };

    return Process;

  })();

  exports.Process = Process;

}).call(this);
