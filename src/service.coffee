{EventEmitter} = require 'events'
{Application} = require './application'
{Dirty} = require 'dirty'
path = require 'path'
mkdirp = require 'mkdirp'

class Service extends EventEmitter
  constructor: (@db_path, @apps_path, callback) ->
    @dirty = new Dirty(@db_path)
    @dirty.on 'load', () =>
      @emit 'ready'
      callback() if callback
    @apps = {}
  
  list: (callback)->
    apps = []
    @dirty.forEach (key, value) -> apps.push(value)
    callback(apps)
  
  create: (app_manifest, callback) ->
    @hasApplication app_manifest.name, (exist) =>
      unless exist
        @enhance app_manifest, (enhanced_manifest) =>
          @dirty.set app_manifest.name, enhanced_manifest, (err) =>
            throw err if err
            @findApplication app_manifest.name, (app) ->
              callback(app)
      else
        callback(false)
  
  update: (name, app_manifest, callback) ->
    @hasApplication name, (exist) =>
      if exist
        @enhance app_manifest, (enhanced_manifest) =>
          @dirty.set name, enhanced_manifest, (err) =>
            throw err if err
            @findApplication app_manifest.name, (app) =>
              callback(app)
      else
        callback(false)

  destroy: (name, callback) ->
    @hasApplication name, (exist) =>
      if exist
        @dirty.set(name, undefined)
        callback(true)
      else
        callback(false)

  # callbacks with the manifest of the found application or undefined
  findManifest: (name, callback) ->
    callback(@dirty.get(name))

  findApplication: (name, callback) ->
    if app = @apps[name]
      callback(app)
    else
      @findManifest name, (manifest) =>
        if manifest
          callback(@apps[name] = new Application(manifest))
        else
          callback(undefined)
  
  allApplications: (callback) ->
    if callback
      @dirty.forEach (name, manifest) =>
        @findApplication name, (app) =>
          callback(app)

  hasApplication: (name, callback) ->
    @findManifest name, (manifest) ->
      callback(manifest != undefined)

  enhance: (manifest, callback) ->
    app_repo_path = @appPath manifest.name, 'repo'
    app_logs_path = @appPath manifest.name, 'logs'

    manifest['logs'] =
      install: path.join app_logs_path, 'install'
      process: path.join app_logs_path, 'process'
      error: path.join app_logs_path, 'error'
    manifest['repo'] ||= {}
    manifest['repo']['dir'] = app_repo_path
    manifest
    
    mkdirp app_logs_path, (err) ->
      throw err if err
      
      mkdirp app_logs_path, (err) ->
        throw err if err
        
        callback(manifest)
  
  bootstrap: (name, callback) ->
    @findApplication app_manifest.name, (app) ->
      app.bootstrap () ->
        callback(app)
  
  appPath: (app_name, app_path) ->
    path.join @apps_path, app_name, app_path
    
exports.Service = Service
