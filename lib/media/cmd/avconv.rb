require 'media'
require 'media/cmd'
require 'shellwords'

module Media
  class Cmd
    class Avconv < Cmd
      STREAM_TYPES_OPTIONS = { audio: 'a', video: 'v' }
      SH_VARS              = Hash[ CONFIG.avtools.avconv.cmd.sh_vars.marshal_dump.map{ |k, v| [k.to_s, v] } ]
      BIN                  = CONFIG.avtools.avconv.cmd.bin
      TIMEOUT              = CONFIG.avtools.avconv.cmd.timeout
      SUBEXEC_TIMEOUT      = TIMEOUT + 10
      SUBEXEC_OPTIONS      = { sh_vars: SH_VARS, timeout: SUBEXEC_TIMEOUT }

      class_attribute :subexec_options, :formats
      class_attribute :codecs, :output_qa, :output_threads, instance_reader: false
      self.subexec_options = SUBEXEC_OPTIONS
      self.formats         = []

      def initialize(input_files, output_file, format = nil)
        if format && !formats.include?(format)
          raise Error.new( 'format unsupported',
                           input_files: input_files, output_file: output_file, formats: formats, format: format )
        end

        @input_files, @output_file, @format = input_files, output_file, format
      end

      private
      def cmd!
        %Q[ #{BIN}
              #{global_options.join(' ')}
              #{input_options_and_input_files}
              #{output_options.join(' ')}
              #{@output_file.shellescape} ].squish
      end

      def input_options_and_input_files
        @input_files.map{ |input| "#{input_options.join(' ')} -i #{input.shellescape}" }.join(' ')
      end

      def global_options(additional_options = [])
        @global_options ||= %W( -loglevel debug -benchmark -y -timelimit #{TIMEOUT.to_s.shellescape} )
        @global_options.concat additional_options
      end

      def input_options(additional_options = [])
        @input_options ||= []
        @input_options.concat additional_options
      end

      def output_options(additional_options = [])
        @output_options ||= default_output_options
        @output_options.concat additional_options
      end

      def default_output_options
        [ strict, sn, output_threads, qv, qa, vbitrate ]
      end

      def strict
        '-strict experimental'
      end

      def sn
        '-sn'
      end

      def qv
        '-q:v 1'
      end

      def qa
        "-q:a #{self.class.output_qa[@format].to_s.shellescape}" if @format
      end

      def achannels
        '-ac 2'
      end

      def ar
        '-ar 44100'
      end

      def codecs
        self.class.codecs[@format] if @format
      end

      def vcodec
        "-c:v #{codecs[0].shellescape}"
      end

      def acodec
        "-c:a #{codecs[1].shellescape}"
      end

      def output_threads
        "-threads #{self.class.output_threads[@format].to_s.shellescape}" if @format
      end

      def vbitrate
        '-b:v 2M' if @format == :webm
      end

    end
  end
end