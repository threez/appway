{AppProcess} = require('../src/app-process')

proc = () -> new AppProcess('web', 'bundle exec daemon.rb')

exports.testConfigruation = (test) ->
  app_process = proc()
  test.equal(app_process.name, 'web')
  test.equal(app_process.command, 'bundle exec daemon.rb')
  test.done()

exports.testScalingDefaults = (test) ->
  app_process = proc()
  test.equal(app_process.scale, 1)
  test.done()

exports.testEnvironmentDefaults = (test) ->
  app_process = proc()
  test.deepEqual(app_process.env, process.env)
  test.done()

exports.testPermissionDefaults = (test) ->
  app_process = proc()
  test.equal(app_process.user, "www-data")
  test.equal(app_process.group, "www-data")
  test.done()
