{EventEmitter} = require 'events'
{Application} = require './application'
{Dirty} = require 'dirty'

class Service extends EventEmitter
  constructor: (@db_path) ->
    @dirty = new Dirty(@db_path)
  
  list:->
    apps = []
    @dirty.forEach (key, value) -> apps.push(value)
    apps
  
  create: (app_manifest) ->
    unless @hasApplication(app_manifest.name)
      @dirty.set(app_manifest.name, app_manifest)
      true
    else
      false
  
  update: (name, app_manifest) ->
    if @hasApplication(name)
      @dirty.set(name, app_manifest)
      true
    else
      false

  destroy: (name) ->
    if @hasApplication(name)
      @dirty.set(name, undefined)
      true
    else
      false

  find: (name) ->
    @dirty.get(name)

  app: (name) ->
    if manifest = @find(name)
      new Application(manifest)

  hasApplication: (name) ->
    @find(name) != undefined

exports.Service = Service
