{EventEmitter} = require 'events'
Hash = require 'hashish'

class Service extends EventEmitter
  constructor: () ->
    @applications = {}
  
  list:->
    Hash(@applications).values
  
  create: (app_manifest) ->
    unless @hasApplication(app_manifest.name)
      @applications[app_manifest.name] = app_manifest
  
  update: (name, app_manifest) ->
    @applications[name] = app_manifest

  destroy: (name) ->
    delete @applications[name]

  find:(name) ->
    @applications[name]

  hasApplication: (name) ->
    @find(name) != undefined

exports.Service = Service
