(function() {
  var EventEmitter, Procfile, readFile;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  readFile = require('fs').readFile;

  EventEmitter = require('events').EventEmitter;

  Procfile = (function() {

    __extends(Procfile, EventEmitter);

    function Procfile(path) {
      var _this = this;
      this.path = path;
      this.config = {};
      this.on('app', function(name, command) {
        return _this.config[name] = command;
      });
    }

    Procfile.prototype.parse = function(callback) {
      var _this = this;
      return readFile(this.path, {
        encoding: 'utf-8'
      }, function(err, data) {
        var line, m, _i, _len, _ref;
        if (err) {
          _this.emit('error', err);
          if (callback) callback(err);
        }
        _ref = data.split("\n");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          line = _ref[_i];
          if (m = line.match(/^([A-Za-z0-9_]+):\s*(.+)$/)) {
            _this.emit('app', m[1], m[2]);
          }
        }
        _this.emit('config', _this.config);
        if (callback) return callback(void 0, _this.config);
      });
    };

    return Procfile;

  })();

  exports.Procfile = Procfile;

}).call(this);
