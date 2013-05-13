
  exports.useLoggerForProcess = function(process, logger) {
    var _this = this;
    if (logger) {
      process.stdout.on('data', function(data) {
        return logger.info(data.toString());
      });
      return process.stderr.on('data', function(data) {
        return logger.error(data.toString());
      });
    }
  };
