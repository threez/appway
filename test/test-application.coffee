{Application} = require '../src/application'
{Service} = require '../src/service'
Tempdir = require 'temporary/lib/dir'
path = require 'path'

installer = (callback) ->
  installer = new Installer()
  callback(installer)

app = (callback) ->
  tmpdir = new Tempdir
  application = new Application
    name: "example"
    repo:
      url: "./example"
      branch: "master"
      dir: tmpdir.path
    packages: {}
    user: "www-data"
    group: "www-data"
    domain: [
      "^example.*",
      "^example.local$"
    ]
    install: [
      "npm install"
    ]
    scale:
      web: 2
  callback(application)
  tmpdir.rmdir()

appFromService = (callback) ->
  service = new Service('./test/app.db', './test/apps')
  service.create app(), callback

exports.testApplication = (test) ->
  app (application) ->
    test.done()
