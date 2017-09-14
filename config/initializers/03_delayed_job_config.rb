DELAYED_JOB = begin
  basename                = File.basename $0
  delayed_jobs_task_regex = /\Ajobs:/

  ( basename == 'delayed_job' ) ||
  ( defined?(Rake) && Rake.try(:application).try(:top_level_tasks) && Rake.application.top_level_tasks.any?{ |v| v =~ delayed_jobs_task_regex } )
end

if DELAYED_JOB
  # The requires are needed by delayed_job jobs (excluding previously loaded initializers)
  require 'media'
  require 'notifications_job'
  require 'eventmachine' unless WINDOWS

  ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new Logger.new LOG_FOLDER.join "delayed_job.activerecord.#{Rails.env}.log"
end

# Delayed::Job configuration
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.max_attempts = 1 if Rails.env.production?
