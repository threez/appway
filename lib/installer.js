(function() {
  var EventEmitter, Installer, spawn, useLoggerForProcess;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  spawn = require('child_process').spawn;

  EventEmitter = require('events').EventEmitter;

  useLoggerForProcess = require('./log-provider').useLoggerForProcess;

  Installer = (function() {

    __extends(Installer, EventEmitter);

    function Installer(dir) {
      this.dir = dir;
    }

    Installer.prototype.install = function(commands, callback) {
      var _this = this;
      return this.processCommand(commands, function(err) {
        if (err) throw err;
        _this.emit('installed');
        if (callback) return callback();
      });
    };

    Installer.prototype.processCommand = function(commands, endCallback) {
      var args, cmd, process;
      var _this = this;
      args = commands.shift();
      cmd = args.shift();
      log.info("Execute: (" + cmd + ") " + args.join(' ') + " @(" + this.dir + ")");
      process = spawn(cmd, args, {
        cwd: this.dir
      });
      useLoggerForProcess(process, this.logger);
      return process.on('close', function(code) {
        var msg;
        if (code === 0) {
          if (commands.length === 0) {
            return endCallback(void 0);
          } else {
            return _this.processCommand(commands, endCallback);
          }
        } else {
          msg = "Command " + cmd + " failed with exit code " + code;
          log.error(msg);
          return endCallback(msg);
        }
      });
    };

    return Installer;

  })();

  exports.Installer = Installer;

}).call(this);
