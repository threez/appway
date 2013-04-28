{Application} = require '../src/application'
{Service} = require '../src/service'

app = () ->
  new Application
    name: "rubynas"
    repo:
      url: "git://github.com/rubynas/rubynas.git"
      branch: "master"
    packages: [
      "ruby1.9.3"
      "ruby-bundler"
      "build-essential"
      "pkg-config"
      "autoconf"
      "automake"
      "libtool"
      "bison"
      "ruby1.9.1-dev"
      "libsqlite3-dev"
      "libreadline6-dev"
      "zlib1g-dev"
      "libssl-dev"
      "libyaml-dev"
      "libxml2-dev"
      "libxslt-dev"
      "libc6-dev"
      "libdb-dev"
      "libsasl2-dev"
      "libxslt-dev"
      "libgdbm-dev"
      "libffi-dev"
    ]
    user: "www-data"
    group: "www-data"
    domain: [
      "^rubynas.*"
      "^rubynas.local$"
    ]
    install: [
      "bundle install --deployment --without test development"
      "bundle exec rake assets:clean assets:precompile"
    ]
    scale:
      web: 2

appFromService = (callback) ->
  service = new Service('./test/app.db', './test/apps')
  service.create app(), callback

exports.testApplication = (test) ->
  application = app()
  test.done()

exports.testInstallPackages = (test) ->
  application = app()
  application.on 'packages-installed', -> test.done()
  application.installPackages()

exports.testDownload = (test) ->
  application = app()
  application.on 'downloaded', -> test.done()
  application.download()

exports.testInstall = (test) ->
  application = app()
  application.on 'installed', -> test.done()
  application.install()

exports.testStart = (test) ->
  application = app()
  application.on 'started', -> test.done()
  application.start()

exports.testStop = (test) ->
  application = app()
  application.on 'stopped', -> test.done()
  application.stop()

exports.testBootstrap = (test) ->
  application = app()
  application.on 'bootstraped', -> test.done()
  application.bootstrap()
