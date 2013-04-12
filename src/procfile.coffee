{readFile} = require 'fs'
{EventEmitter} = require 'events'

# This class parses the procfile. The following events are emitted:
# 'app' for every app with (name, command)
# 'config' after parsing finished with a (config) hash
# 'error' if there is a problem reading the file with the (error) object
class Procfile extends EventEmitter
  constructor: (@path) ->
    @config = {}
    @on 'app', (name, command) =>
      @config[name] = command

  parse: ->
    readFile @path, { encoding: 'utf-8' }, (err, data) =>
      @emit 'error', err if err
      for line in data.split "\n"
        if m = line.match /^([A-Za-z0-9_]+):\s*(.+)$/
          @emit 'app', m[1], m[2]
      @emit 'config', @config

exports.Procfile = Procfile
