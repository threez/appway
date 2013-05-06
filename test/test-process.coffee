{Process} = require '../src/process'

proc = () -> new Process({}, 'web', 'bundle exec daemon.rb')

exports.testConfigruation = (test) ->
  app_process = proc()
  test.equal(app_process.category, 'web')
  test.deepEqual(app_process.command, ['env', 'bundle', 'exec', 'daemon.rb'])
  test.done()

exports.testEnvironmentDefaults = (test) ->
  app_process = proc()
  test.deepEqual app_process.env,
    PATH: process.env['PATH']
    SHELL: process.env['SHELL']
    TMPDIR: process.env['TMPDIR']
  test.done()

exports.testPermissionDefaults = (test) ->
  app_process = proc()
  test.equal(app_process.user, "www-data")
  test.equal(app_process.group, "www-data")
  test.done()
