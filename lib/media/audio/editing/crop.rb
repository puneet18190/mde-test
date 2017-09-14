require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/video/editing/crop'
require 'media/logging'
require 'media/audio/editing/cmd/crop'

module Media
  module Audio
    module Editing
      # Crop the input audios supplied producing shorter output audios - see Media::Video::Editing::Crop
      class Crop < Video::Editing::Crop
  
        include Logging

        # Output formats
        FORMATS  = FORMATS
        # Crop command class
        CROP_CMD = Cmd::Crop
      end
    end
  end
end
