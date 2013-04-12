{Procfile} = require('../src/procfile')

exports.testParsing = (test) ->
  test.expect 1
  procfile = new Procfile('test/fixtures/Procfile')
  procfile.on 'config', (config) ->
    test.deepEqual config,
      web: "bundle exec puma -p $PORT"
      daemon: "bundle exec daemon.rb"
    test.done()
  procfile.parse()
