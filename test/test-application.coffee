{Application} = require('../src/application')

app = () -> new Application('web', 'bundle exec daemon.rb')

exports.testConfigruation = (test) ->
  application = app()
  test.equal(application.name, 'web')
  test.equal(application.command, 'bundle exec daemon.rb')
  test.done()

exports.testScalingDefaults = (test) ->
  application = app()
  test.equal(application.scale, 1)
  test.done()

exports.testEnvironmentDefaults = (test) ->
  application = app()
  test.deepEqual(application.env, process.env)
  test.done()

exports.testPermissionDefaults = (test) ->
  application = app()
  test.equal(application.user, "www-data")
  test.equal(application.group, "www-data")
  test.done()
