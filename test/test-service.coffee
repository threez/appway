{Service} = require '../src/service'

exports.testEmptyList = (test) ->
  service = new Service()
  test.equal(service.list().length, 0)
  test.done()

exports.testAddNewApplication = (test) ->
  service = new Service()
  test.equal(service.create(name: 'foo'), true)
  test.deepEqual(service.list(), [{ name: 'foo' }])
  test.done()

exports.testDontAddSameTwice = (test) ->
  service = new Service()
  test.equal(service.create(name: 'foo'), true)
  test.equal(service.create(name: 'foo'), false)
  test.deepEqual(service.list(), [{ name: 'foo' }])
  test.done()

exports.testFindApplication = (test) ->
  service = new Service()
  test.equal(service.create(name: 'foo'), true)
  test.deepEqual(service.find('foo'), { name: 'foo' })
  test.done()

exports.testReplaceAnApplication = (test) ->
  service = new Service()
  test.equal(service.create(name: 'foo'), true)
  test.equal(service.update('foo', name: 'foo2'), true)
  test.deepEqual(service.list(), [{ name: 'foo2' }])
  test.done()

exports.testNoReplacementIfNotExists = (test) ->
  service = new Service()
  test.equal(service.update('foo', name: 'foo2'), false)
  test.equal(service.list().length, 0)
  test.done()

exports.testRemoveAnApplication = (test) ->
  service = new Service()
  test.equal(service.create(name: 'foo'), true)
  test.equal(service.destroy('foo'), true)
  test.deepEqual(service.list().length, 0)
  test.done()

exports.testRemoveAnApplicationIfNotExists = (test) ->
  service = new Service()
  test.equal(service.destroy('foo'), false)
  test.done()
