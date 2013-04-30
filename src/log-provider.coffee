exports.useLoggerForProcess = (process, logger) ->
  if logger
    process.stdout.on 'data', (data) =>
      logger.info data.toString()
    process.stderr.on 'data', (data) =>
      logger.error data.toString()
