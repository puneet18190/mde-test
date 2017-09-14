require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/audio/editing/conversion'

module Media
  module Audio
    module Editing
      class Conversion
        # DelayedJob for conversion processings
        class Job < Struct.new(:uploaded_path, :output_path_without_extension, :original_filename, :model_id)
          # Performs the job
          def perform
            Conversion.new(uploaded_path, output_path_without_extension, original_filename, model_id).run
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