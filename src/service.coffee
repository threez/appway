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
      true
    else
      false
  
  update: (name, app_manifest) ->
    if @applications[name]
      @applications[name] = app_manifest
      true
    else
      false

  destroy: (name) ->
    if @applications[name]
      delete @applications[name]
      true
    else
      false

  find:(name) ->
    @applications[name]

  hasApplication: (name) ->
    @find(name) != undefined

exports.Service = Service
