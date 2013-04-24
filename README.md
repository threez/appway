# Procserver (DRAFT)

The procfile server.

The proserver is inspired by heroku a deployment mechanism and is designed for rubynas but may also work for others.

The main design goal is to have a simple deployment mechanism for multiple procfile based applications. Because the procfile allows applications based on ruby, nodejs, python.

Special with this server is, that it has a build in reverse-proxy and therefore has no need for something like nginx or apache. The procfile server runs as `root` and listens on port `80`.

Because the Procserver will host multiple applications on the same host it supports different types of virtual application/webserver proxying:

1. **Host** based: Like `rubynas.appserver.local`
2. **X-App** based: Like `X-App: rubynas`. This is an alternative to make requests using AJAX to multiple applications on the same host without changing the host really.
3. **Request Path** based: Like `appserver.local/rubynas`
4. **Port based** based: Like `appserver.local:8001`. Actually this is not a proxy request, it is connecting to the application directly.

## Deployment

The deployment of the procfile server usually happens as a debian package or something similar. Which than uses git repositories to deploy services.

## Configuration

The main requirement for the deployed application is a `Procfile`. The `Procfile` works as the main application manifest, but not all information can be gatherd by it, the rest will be passed when the application is installed. The second requirement is a git repository where the application code can be fetched.

Example Procfile:

    web: puma -p $PORT

The rest of the application is configured by the application environment.

### Procfile

The `Procfile` ist standard an works as described in foreman. Special is the treatment of environemnt variabes, which get overwritten in some parts:

1. The default process environment is used
2. The .env file is applyed
3. The application server based config options are set (db config etc.)
4. Process specific variables like port numbers are applyed

## API

The profile-server has a restful api to install new applications and so stuff with them.

### Add new application

    POST /applications

Content:

    {
      name: "rubynas",
      repo: {
        url: "git://github.com/rubynas/rubynas.git",
        branch: "master"
      },
      packages: [
        "ruby1.9.3",
        "ruby-bundler",
        "build-essential",
        "pkg-config",
        "autoconf",
        "automake",
        "libtool",
        "bison",
        "ruby1.9.1-dev",
        "libsqlite3-dev",
        "libreadline6-dev",
        "zlib1g-dev",
        "libssl-dev",
        "libyaml-dev",
        "libxml2-dev",
        "libxslt-dev",
        "libc6-dev",
        "libdb-dev",
        "libsasl2-dev",
        "libxslt-dev",
        "libgdbm-dev",
        "libffi-dev"
      ],
      user: "www-data",
      group: "www-data",
      domain: [
        "^rubynas.*",
        "^rubynas.local$"
      ],
      install: [
        "bundle install --deployment --without test development",
        "bundle exec rake assets:clean assets:precompile",
      ],
      scale: {
        web: 2
      }
    }

Parts of the request:

* **name**: The name with that the application will be referenced later
* **repo**: The location of the git repository
  * **url**: The path to a git repository
  * **branch** (optional): The branch to checkout (default master)
* **packages**: Required packages (e.g. on ubuntu debian) that need to be installed before
* **user**: The user under which the application should be started
* **group**: The group under which the application should be started
* **domain**: A list of regular expressions that declare, under which requests the application should respond.
* **install** (optional): A list of commands that should be executed to prepare the application start.
* **scale** (optional): A list of profile processes and there scaling factor.

This request will:

1. Install the required pakages using `apt-get`on ubuntu
2. Clone the git repository (git pull/clone) and start the application
3. Execute the install commands
4. Run (execute procfile)

Limitation: The application has no write access to the file system in the checkout folder.

For the application server itself there is a configuration directory that includes all applications that should be deployed: The the directory is by default `/etc/procserver/config`.

### View logs

    GET /applications/rubynas/logs/<logname>
    
The logname can be either:

1. `stdout`: Normal application output informational level
2. `stderr`: Errors and exceptions reported by the application
3. `install`: A recording of the actions happening during the installation. This includes stderr and stdout of the output of all commands executed.
  
### Start/Stop/Restart/Redeploy

    POST /applications/rubynas/<action>
    
The action can either be:

1. `start`
2. `restart`
3. `stop`
4. `redeploy`: A redeploy will do stop the service update the code and run the install step. Finally it starts the application.
    
### Undeploy the application

    DELETE /applications/rubynas

### List all installed applications

    GET /applications

Result:

    [
      { name: "rubynas" }
    ]

### Inspect application configuration

    GET /applications/rubynas

This will return the configuration of the application.

### Update the configuration of a service

    PUT /applications/rubynas

This request accepts the same input as the *Add new application* request. After changing the config, all installation steps, like with the creation of a new service take place.

## Dependencies:

* [http://expressjs.com/](http://expressjs.com/) for the api requests
* [https://github.com/substack/bouncy](https://github.com/substack/bouncy) for proxying
* [https://github.com/visionmedia/send](https://github.com/visionmedia/send) for static content hosting

## Acknowledgements

Some of the code is inspired by [norman](https://github.com/josh/norman/).
