{Service} = require '../src/service'
{Application} = require '../src/application'
Tempdir = require 'temporary/lib/dir'

testService = (callback) ->
  tmpdir = new Tempdir
  service = new Service(tmpdir.path + '/service.db', tmpdir.path)
  callback(service)

exports.testEmptyList = (test) ->
  testService (service) ->
    service.list (list) ->
      test.equal(list.length, 0)
      test.done()

exports.testAddNewApplication = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.list (list) ->
        test.equal(list[0].name, 'foo')
        test.done()

exports.testDontAddSameTwice = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.create name: 'foo', (app) ->
        test.equal(app, false)
        service.list (list) ->
          test.equal(list[0].name, 'foo')
          test.done()

exports.testFindApplication = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.findManifest 'foo', (manifest) ->
        test.equal(manifest.name, 'foo')
        test.done()
  
exports.testNotFindApplication = (test) ->
  testService (service) ->
    service.findManifest 'foo', (manifest) ->
      test.equal(manifest, undefined)
      test.done()

exports.testReplaceAnApplication = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.update 'foo', name: 'foo2', (app) ->
        test.notEqual(app, false)
        service.list (list) ->
          test.equal(list[0].name, 'foo2')
          test.done()

exports.testNoReplacementIfNotExists = (test) ->
  testService (service) ->
    service.update 'foo', name: 'foo2', (app) ->
      test.equal(app, false)
      service.list (list) ->
        test.equal(list.length, 0)
        test.done()

exports.testRemoveAnApplication = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.destroy 'foo', (result) ->
        test.equal(result, true)
        service.list (list) ->
          test.equal(list.length, 0)
          test.done()

exports.testRemoveAnApplicationIfNotExists = (test) ->
  testService (service) ->
    service.destroy 'foo', (result) ->
      test.equal(result, false)
      test.done()

exports.testFindApplicationObject = (test) ->
  testService (service) ->
    service.create name: 'foo', (app) ->
      test.notEqual(app, false)
      service.findApplication 'foo', (app2) ->
        test.deepEqual(app, app2)
        test.done()

exports.testNotFindApplicationObject = (test) ->
  testService (service) ->
    service.findApplication 'foo', (app) ->
      test.equal(app, undefined)
      test.done()
