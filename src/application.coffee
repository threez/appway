class Application
  constructor: (@name, @command) ->
    @scale = 1
    @env = process.env
    @user = "www-data"
    @group = "www-data"
    
  
exports.Application = Application
