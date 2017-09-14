require 'media'
require 'media/cmd'
require 'shellwords'

module Media
  class Cmd
    class Avprobe < Cmd
      SH_VARS         = Hash[ CONFIG.avtools.avprobe.cmd.sh_vars.marshal_dump.map{ |k, v| [k.to_s, v] } ]
      BIN             = CONFIG.avtools.avprobe.cmd.bin
      SUBEXEC_OPTIONS = { sh_vars: SH_VARS, timeout: CONFIG.avtools.avprobe.cmd.subexec_timeout }
      
      self.subexec_options = SUBEXEC_OPTIONS

      def initialize(input_file)
        @input_file = input_file
      end

      def run(stdout = nil, stderr = nil)
        super
      end

      private
      def cmd!
        %Q[ #{BIN.shellescape} #{@input_file.shellescape} ].squish
      end

    end
  end
end