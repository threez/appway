{Service} = require '../src/service'

exports.testEmptyList = (test) ->
  service = new Service()
  test.equal(service.list().length, 0)
  test.done()

exports.testAddNewApplication = (test) ->
  service = new Service()
  service.create name: 'foo'
  test.deepEqual(service.list(), [{ name: 'foo' }])
  test.done()

exports.testDontAddSameTwice = (test) ->
  service = new Service()
  service.create name: 'foo'
  service.create name: 'foo'
  test.deepEqual(service.list(), [{ name: 'foo' }])
  test.done()

exports.testFindApplication = (test) ->
  service = new Service()
  service.create name: 'foo'
  test.deepEqual(service.find('foo'), { name: 'foo' })
  test.done()

exports.testReplaceAnApplication = (test) ->
  service = new Service()
  service.create name: 'foo'
  service.update 'foo', name: 'foo2'
  test.deepEqual(service.list(), [{ name: 'foo2' }])
  test.done()

exports.testRemoveAnApplication = (test) ->
  service = new Service()
  service.create name: 'foo'
  service.destroy 'foo'
  test.deepEqual(service.list().length, 0)
  test.done()
