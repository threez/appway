(function() {
  var EventEmitter, Repository, fs, path, spawn, useLoggerForProcess;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  spawn = require('child_process').spawn;

  useLoggerForProcess = require('./log-provider').useLoggerForProcess;

  fs = require('fs');

  path = require('path');

  Repository = (function() {

    __extends(Repository, EventEmitter);

    function Repository(config, logger) {
      var _this = this;
      this.config = config;
      this.logger = logger;
      this.on('pulled', function() {
        return _this.emit('synced');
      });
      this.on('cloned', function() {
        return _this.emit('synced');
      });
    }

    Repository.prototype.sync = function(callback) {
      var _this = this;
      return fs.exists(path.join(this.config.dir, '.git'), function(exists) {
        if (exists) {
          return _this.pull(callback);
        } else {
          return _this.clone(callback);
        }
      });
    };

    Repository.prototype.pull = function(callback) {
      var process;
      var _this = this;
      process = spawn('env', this.pullArgs(), {
        cwd: this.config.dir
      });
      useLoggerForProcess(process, this.logger);
      return process.on('close', function(code) {
        if (code === 0) {
          _this.emit('pulled');
          if (callback) return callback(void 0, _this);
        } else {
          _this.emit('error', code);
          if (callback) return callback('unable to pull', _this);
        }
      });
    };

    Repository.prototype.clone = function(callback) {
      var process;
      var _this = this;
      process = spawn('env', this.cloneArgs());
      useLoggerForProcess(process, this.logger);
      return process.on('close', function(code) {
        if (code === 0) {
          _this.emit('cloned');
          if (callback) return callback(void 0, _this);
        } else {
          _this.emit('error', code);
          if (callback) return callback('unable to clone', _this);
        }
      });
    };

    Repository.prototype.pullArgs = function() {
      var args;
      return args = ['git', 'pull'];
    };

    Repository.prototype.cloneArgs = function() {
      var args;
      args = ['git', 'clone'];
      if (this.config.branch) {
        args.push('-b');
        args.push(this.config.branch);
      }
      args.push('--');
      args.push(this.config.url);
      args.push(this.config.dir);
      return args;
    };

    return Repository;

  })();

  exports.Repository = Repository;

}).call(this);
