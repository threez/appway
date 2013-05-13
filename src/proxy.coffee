httpProxy = require 'http-proxy'

# The proxy is one of the main building blocks of this server. It knows where
# (on which port) an app is deployed and will proxy to the application in
# different ways.
#
# == IMPLEMENTED ==
# 1. Proxy using the name. I the "X-App" header contains a known application
#    name the server will proxy to the corresponding application.
#
# == NOT IMPLEMENTED ==
# 2. Proxy using a dns / domain regex. If the header matches the domain config
#    of the application. ()
# 3. The application port is used.
# 4. Using a path in the request.
#
class Proxy
  constructor: (startPort) ->
    @localhost = '127.0.0.1'
    @global = '0.0.0.0'
    @startPort = startPort || 5000
    @maxPorts = 1000
    @endPort = @startPort + @maxPorts
    @ports = {}
    @apps = {}
    @appHeader = "x-app"
    @loadBalancer = {}
    
    @server = httpProxy.createServer (req, res, proxy) =>
      # Proxy using app name (Header)
      if appName = req.headers[@appHeader]
        if port = @portForApp(appName)
          # redirect to the application
          proxy.proxyRequest req, res,
            host: @localhost
            port: port
        else
          # App not found
          @clientError res, "Error: app '#{appName}' don't exist!"
      else
        # No app passed
        @clientError res, "Error: Need to pass the 'X-App' Header"

  portForApp: (appName) ->
    if ports = @apps[appName]
      @loadBalancer[appName] += 1
      port = ports[@loadBalancer[appName] % ports.length]
      port

  # Register the application and start it so that the proxy can start proxying
  # requests to it.
  # @param [String] name
  # @param [Process] app the app process
  registerApp: (name, app) ->
    port = @registerPort(name, app)
    app.listen(port, @localhost)
    log.info "Started app '#{app.name()}' on #{@localhost}:#{port}",
      app: app.name()

  # Register the application and find a free port for it.
  # @param [String] name
  # @param [Process] app the app process
  registerPort: (name, app) ->
    for port in [@startPort..@endPort]
      unless @ports[port]
        # Register the port for the application
        @ports[port] = app
        
        # Create application name base lookups for ports
        @apps[name] ||= []
        @apps[name].push port
        @loadBalancer[name] ||= 0

        return port

  # Unregister the passed application from the proxy
  # @param [String] name
  # @param [Process] app the app process
  unregisterApp: (name, app) ->
    # find the process / app by the app port
    process = @ports[app.port]
    delete @ports[app.port]
    
    # unadvertise the port of the app
    index = @apps[name].indexOf(app.port)
    # by creating a new apps array based on the old, just with the app.port
    # removed. This is a little bit tricky in javascript
    @apps[name] = @apps[name].slice(0, index).concat(
      @apps[name].slice(index + 1, @apps[name].length))
    
    log.info "Removed app '#{app.name()}' from #{@localhost}:#{app.port}",
      app: app.name()
    
    # remove the whole app if there is no more port for the app
    if @apps[name].length == 0
      delete @apps[name]
      delete @loadBalancer[name]
      log.info "Removed app #{name} completely",
        app: app.name()
    
  # Starts the http proxy server
  listen: (port) ->
    @server.listen(port, @global)
    log.info "Started proxy on #{@global}:#{port}"

  # Respond to a client error with the passed message
  clientError: (res, errorText) ->
    res.writeHead 400, 'Content-Type': 'text/plain'
    res.end "#{errorText}\n"

exports.Proxy = Proxy
