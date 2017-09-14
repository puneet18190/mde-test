require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/composer'

module Media
  module Video
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
