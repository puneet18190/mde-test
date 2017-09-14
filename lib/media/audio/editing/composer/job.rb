require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/audio/editing/composer'

module Media
  module Audio
    module Editing
      class Composer
        # DelayedJob for composing processings
        class Job < Struct.new(:params)
          # Performs the job
          def perform
            Composer.new(params).run
          rescue => e
            ExceptionLogger.log e
            ExceptionNotifier.notify_exception e
            raise e
          end
        end
      end
    end
  end
end
