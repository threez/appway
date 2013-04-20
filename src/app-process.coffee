class AppProcess
  constructor: (@name, @command) ->
    @scale = 1
    @env = process.env
    @user = "www-data"
    @group = "www-data"

exports.AppProcess = AppProcess
