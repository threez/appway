{EventEmitter} = require 'events'
{Application} = require './application'
{Dirty} = require 'dirty'
path = require 'path'
mkdirp = require 'mkdirp'

class Service extends EventEmitter
  constructor: (@db_path, @apps_path) ->
    @dirty = new Dirty(@db_path)
    @apps = {}
  
  list:->
    apps = []
    @dirty.forEach (key, value) -> apps.push(value)
    apps
  
  create: (app_manifest) ->
    unless @hasApplication(app_manifest.name)
      @dirty.set(app_manifest.name, @enhance(app_manifest))
      @app(app_manifest.name).bootstrap()
      true
    else
      false
  
  update: (name, app_manifest) ->
    if @hasApplication(name)
      @dirty.set(name, @enhance(app_manifest))
      @app(name).bootstrap()
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
    if app = @apps[name]
      app
    else
      if manifest = @find(name)
        @apps[name] = new Application(manifest)

  hasApplication: (name) ->
    @find(name) != undefined
    
  enhance: (manifest) ->
    mkdirp.sync(app_repo_path = @appPath manifest.name, 'repo')
    mkdirp.sync(app_logs_path = @appPath manifest.name, 'logs')
    
    manifest['logs'] =
      install: path.join app_logs_path, 'install'
      process: path.join app_logs_path, 'process'
      error: path.join app_logs_path, 'error'
    manifest['repo'] ||= {}
    manifest['repo']['dir'] = app_repo_path
    manifest
  
  appPath: (app_name, app_path) ->
    path.join @apps_path, app_name, app_path
    
exports.Service = Service
