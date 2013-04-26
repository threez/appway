{Service} = require './service'
express = require 'express'
send = require 'send'

class Api
  constructor: () ->
    @service = new Service("./app.db", "./apps")
    @app = express()

    @app.use(express.logger('dev')) # 'default', 'short', 'tiny', 'dev'
    @app.use(express.bodyParser())

    @app.get '/applications', (req, res) =>
      res.json @service.list()

    @app.post '/applications', (req, res) =>
      console.log(req.body)
      if @service.create(req.body)
        res.send(200)
      else
        res.send(409, error: 'Conflict, the applications already exists')

    @app.get '/applications/:name', (req, res) =>
      if app = @service.find(req.params.name)
        res.json app
      else
        res.send(404, error: 'The application is not defined')

    @app.put '/applications/:name', (req, res) =>
      if @service.update(req.params.name, req.body)
        res.send(200)
      else
        res.send(404, error: 'The application is not defined')

    @app.del '/applications/:name', (req, res) =>
      if @service.destroy(req.params.name)
        res.send(200)
      else
        res.send(404, error: 'The application is not defined')

    @app.get '/applications/:name/logs/:log', (req, res) =>
      if app = @service.app(req.params.name)
        send(req, app.log(req.params.log)).pipe(res)
      else
        res.send(404, error: 'The application is not defined')

    @app.post '/applications/:name/start', (req, res) =>
      if app = @service.app(req.params.name)
        res.json = app.start
      else
        res.send(404, error: 'The application is not defined')

    @app.post '/applications/:name/restart', (req, res) =>
      if app = @service.app(req.params.name)
        res.json app.restart
      else
        res.send(404, error: 'The application is not defined')

    @app.post '/applications/:name/stop', (req, res) =>
      if app = @service.app(req.params.name)
        res.json app.stop
      else
        res.send(404, error: 'The application is not defined')

    @app.post '/applications/:name/redeploy', (req, res) =>
      if app = @service.app(req.params.name)
        res.json app.redeploy
      else
        res.send(404, error: 'The application is not defined')

exports.Api = Api
