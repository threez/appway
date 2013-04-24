{Service} = require './service'
express = require 'express'

class Api
  constructor: () ->
    @service = new Service()
    @app = express()
    
    # validate the existance of the passed application
    checkName = (req, res, next) =>
      console.log("Check for application:", req.params.name)
      unless @service.hasApplication(req.params.name)
        res.send(404, "Application dosn't exists!")
      else
        next()

    @app.get '/applications', (req, res) =>
      res.json @service.list()
      
    @app.post '/applications', (req, res) =>
      result = @service.create(req.body) 
      res.send result ? 'ok' : result
      
    @app.get '/applications/:name', checkName, (req, res) =>
      res.json = @service.find(req.params.name)
      
    @app.put '/applications/:name', checkName, (req, res) =>
      result = @service.update(req.params.name, req.body) 
      res.send result ? 'ok' : result
    
    @app.get '/applications/:name/logs/:log', checkName, (req, res) =>
      res.send @service.log(req.params.name, req.params.log)
      
    @app.post '/applications/:name/start', checkName, (req, res) =>
      res.send @service.start(req.params.name)
      
    @app.post '/applications/:name/restart', checkName, (req, res) =>
      res.send @service.restart(req.params.name)
      
    @app.post '/applications/:name/stop', checkName, (req, res) =>
      res.send @service.stop(req.params.name)
      
    @app.post '/applications/:name/redeploy', checkName, (req, res) =>
      res.send @service.redeploy(req.params.name)
      
    @app.del '/applications/:name', checkName, (req, res) =>
      res.send @service.destroy(req.params.name)

exports.Api = Api
