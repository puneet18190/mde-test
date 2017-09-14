require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/audio/editing/cmd'
require 'shellwords'

module Media
  module Audio
    module Editing
      class Cmd
        # CLI for audio editing using Sox
        class Sox < Cmd
          # sox executable
          BIN                    = SOX_BIN.shellescape
          # Sox global options
          GLOBAL_OPTIONS         = SOX_GLOBAL_OPTIONS.map(&:shellescape).join(' ')
          # Sox executable joined with the global options
          BIN_AND_GLOBAL_OPTIONS = "#{BIN} #{GLOBAL_OPTIONS}"
        end
      end
    end
  end
end
