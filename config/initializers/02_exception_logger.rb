require 'pp'

LOG_FOLDER = Pathname(Rails.application.config.paths['log'].first).dirname

module ExceptionLogger
  # Path to the errors log file
  LOG_PATH = LOG_FOLDER.join "exceptions.#{Rails.env}.log"
  # logger instance
  LOGGER   = Logger.new(LOG_PATH)

  LOGGER.level     = Logger::ERROR
  LOGGER.formatter = Logger::Formatter.new

  # Logs exception together with an env hash (which can be +nil+)
  def self.log(exception, env = nil)
    pp_env      = PP.pp env, ''
    log_content = { message: exception.message, backtrace: exception.backtrace.join("\n"), env: pp_env }.to_yaml

    LOGGER.error <<-LOG

-- BEG EXCEPTION (#{exception.class}) --
#{log_content}
-- END EXCEPTION (#{exception.class}) --
LOG
  end
end
