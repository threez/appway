{Installer} = require '../src/installer'
Tempdir = require 'temporary/lib/dir'

installer = (callback) ->
  tmpdir = new Tempdir
  installer = new Installer(tmpdir.path)
  callback(installer)
  installer.on 'installed', () -> tmpdir.rmdir()

exports.testCommandExecution = (test) ->
  installer (obj) ->
    obj.install [['touch', 'foo', 'bar'], ['ls'], ['rm', 'foo'], ['rm', 'bar']]
    test.done()
