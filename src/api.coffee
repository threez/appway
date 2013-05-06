{Service} = require './service'
{ProcessManager} = require './process-manager'
express = require 'express'
send = require 'send'

class Api
  constructor: () ->
    @app = express()
    @app.use express.logger('dev') # 'default', 'short', 'tiny', 'dev'
    @app.use express.bodyParser()

    @app.get '/applications', (req, res) =>
      @service.list (list) ->
        res.json list

    @app.post '/applications', (req, res) =>
      @service.create req.body, (app) =>
        if app
          @processManager.redeploy app, (result) ->
            res.send(200) # TODO: react to result
        else
          res.send(409, error: 'Conflict, the applications already exists')

    @app.get '/applications/:name', (req, res) =>
      @service.findManifest req.params.name, (manifest) ->
        if manifest
          res.json manifest
        else
          res.send(404, error: 'The application is not defined')

    @app.put '/applications/:name', (req, res) =>
      @service.update req.params.name, req.body, (app) =>
        if app
          @processManager.redeploy app, (result) ->
            res.send(200) # TODO: react to result
        else
          res.send(404, error: 'The application is not defined')

    @app.del '/applications/:name', (req, res) =>
      @service.destroy req.params.name, (result) =>
        if result
          res.send(200)
        else
          res.send(404, error: 'The application is not defined')

    @app.get '/applications/:name/logs/:log', (req, res) =>
      @findApplication req, res, (app) =>
        send(req, app.log(req.params.log)).pipe(res)

    @app.post '/applications/:name/start', (req, res) =>
      @findApplication req, res, (app) =>
        @processManager.start app, (result) ->
          res.send(200) # TODO: react to result

    @app.post '/applications/:name/restart', (req, res) =>
      @findApplication req, res, (app) =>
        @processManager.restart app, (result) ->
          res.send(200) # TODO: react to result

    @app.post '/applications/:name/stop', (req, res) =>
      @findApplication req, res, (app) =>
        @processManager.stop app, (result) ->
          res.send(200) # TODO: react to result

    @app.post '/applications/:name/redeploy', (req, res) =>
      @findApplication req, res, (app) =>
        @processManager.redeploy app, (result) ->
          res.send(200) # TODO: react to result

  # Checks if the application exists
  # @param [HttpRequest] req
  # @param [HttpResponse] res
  # @param [Function] callback
  findApplication: (req, res, callback) ->
    @service.findApplication req.params.name, (app) =>
      if app
        callback(app)
      else
        res.send(404, error: 'The application is not defined')
  
  # Returns the name of the application.
  # @return [String]
  name: () ->
    "appway-api"
  
  # Setter for the service which manipulates the applications. The service
  # is the main object that is exposed with this api.
  # @param [Service] service
  setService: (@service) ->
  
  # Setter for the process manager, that is used to deploy and start the
  # application
  # @param [ProcessManager] processManager
  setProcessManager: (@processManager) ->
  
  # Start the application api on passed port and host.
  # @param [Integer] port
  # @port [String] host e.g. '0.0.0.0'
  listen: (port, host) ->
    @app.listen(port, host)
    
exports.Api = Api
