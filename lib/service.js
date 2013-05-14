(function() {
  var Application, Dirty, EventEmitter, Service, mkdirp, path;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  Application = require('./application').Application;

  Dirty = require('dirty').Dirty;

  path = require('path');

  mkdirp = require('mkdirp');

  Service = (function() {

    __extends(Service, EventEmitter);

    function Service(db_path, apps_path, callback) {
      var _this = this;
      this.db_path = db_path;
      this.apps_path = apps_path;
      this.dirty = new Dirty(this.db_path);
      this.dirty.on('load', function() {
        _this.emit('ready');
        if (callback) return callback();
      });
      this.apps = {};
    }

    Service.prototype.list = function(callback) {
      var apps;
      apps = [];
      this.dirty.forEach(function(key, value) {
        return apps.push(value);
      });
      return callback(apps);
    };

    Service.prototype.create = function(app_manifest, callback) {
      var _this = this;
      return this.hasApplication(app_manifest.name, function(exist) {
        if (!exist) {
          return _this.enhance(app_manifest, function(enhanced_manifest) {
            return _this.dirty.set(app_manifest.name, enhanced_manifest, function(err) {
              if (err) throw err;
              return _this.findApplication(app_manifest.name, function(app) {
                return callback(app);
              });
            });
          });
        } else {
          return callback(false);
        }
      });
    };

    Service.prototype.update = function(name, app_manifest, callback) {
      var _this = this;
      return this.hasApplication(name, function(exist) {
        if (exist) {
          return _this.enhance(app_manifest, function(enhanced_manifest) {
            return _this.dirty.set(name, enhanced_manifest, function(err) {
              if (err) throw err;
              return _this.findApplication(app_manifest.name, function(app) {
                return callback(app);
              });
            });
          });
        } else {
          return callback(false);
        }
      });
    };

    Service.prototype.destroy = function(name, callback) {
      var _this = this;
      return this.hasApplication(name, function(exist) {
        if (exist) {
          return _this.dirty.rm(name, function() {
            return callback(true);
          });
        } else {
          return callback(false);
        }
      });
    };

    Service.prototype.findManifest = function(name, callback) {
      return callback(this.dirty.get(name));
    };

    Service.prototype.findApplication = function(name, callback) {
      var app;
      var _this = this;
      if (app = this.apps[name]) {
        return callback(app);
      } else {
        return this.findManifest(name, function(manifest) {
          if (manifest != null) {
            return callback(_this.apps[name] = new Application(manifest, _this.log));
          } else {
            return callback(void 0);
          }
        });
      }
    };

    Service.prototype.allApplications = function(callback) {
      var _this = this;
      if (callback) {
        return this.dirty.forEach(function(name, manifest) {
          return _this.findApplication(name, function(app) {
            if (app != null) return callback(app);
          });
        });
      }
    };

    Service.prototype.hasApplication = function(name, callback) {
      return this.findManifest(name, function(manifest) {
        return callback(manifest !== void 0);
      });
    };

    Service.prototype.enhance = function(manifest, callback) {
      var app_repo_path;
      app_repo_path = path.join(this.apps_path, manifest.name);
      manifest['repo'] || (manifest['repo'] = {});
      manifest['repo']['dir'] = app_repo_path;
      manifest;
      return mkdirp(app_repo_path, function(err) {
        if (err) throw err;
        return callback(manifest);
      });
    };

    Service.prototype.bootstrap = function(name, callback) {
      return this.findApplication(app_manifest.name, function(app) {
        return app.bootstrap(function() {
          return callback(app);
        });
      });
    };

    return Service;

  })();

  exports.Service = Service;

}).call(this);
