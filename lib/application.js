(function() {
  var Application, EventEmitter, Installer, Procfile, Repository, path, spawn;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  Repository = require('./repository').Repository;

  Installer = require('./installer').Installer;

  Procfile = require('./procfile').Procfile;

  spawn = require('child_process').spawn;

  path = require('path');

  Application = (function() {

    __extends(Application, EventEmitter);

    function Application(manifest) {
      this.manifest = manifest;
    }

    Application.prototype.name = function() {
      return this.manifest.name;
    };

    Application.prototype.dir = function() {
      return this.manifest.repo.dir;
    };

    Application.prototype.deploy = function(callback) {
      var _this = this;
      return this.installPackages(function() {
        return _this.download(function() {
          return _this.install(function() {
            _this.emit('deployed');
            if (callback) return callback();
          });
        });
      });
    };

    Application.prototype.installPackages = function(callback) {
      var cmds, installer, packages;
      var _this = this;
      if (packages = this.manifest.packages["apt-get"]) {
        cmds = [['apt-get', 'update'], ['apt-get', 'install', '-y', packages.join(' ')]];
        installer = new Installer(void 0, log, this);
        return installer.install(cmds, function(err) {
          if (err) throw err;
          _this.emit('packages-installed');
          if (callback) return callback();
        });
      } else {
        log.warn('Skipped install of packages!', {
          app: this.name()
        });
        this.emit('packages-installed');
        if (callback) return callback();
      }
    };

    Application.prototype.download = function(callback) {
      var repository;
      var _this = this;
      repository = new Repository(this.manifest.repo, log, this);
      return repository.sync(function(err) {
        if (err) throw err;
        _this.emit('downloaded', _this, repository);
        if (callback) return callback(_this, repository);
      });
    };

    Application.prototype.install = function(callback) {
      var cmds, installer;
      var _this = this;
      cmds = [];
      this.manifest.install.forEach(function(cmd) {
        return cmds.push(cmd.split(/\s+/));
      });
      installer = new Installer(this.manifest.repo.dir, log, this);
      return installer.install(cmds, function(err) {
        if (err) throw err;
        _this.emit('installed');
        if (callback) return callback();
      });
    };

    return Application;

  })();

  exports.Application = Application;

}).call(this);
