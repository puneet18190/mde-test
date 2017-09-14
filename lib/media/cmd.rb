require 'media'
require 'subexec'

module Media

  # Media::Cmd is an interface for running shell commands using {Subexec}[https://github.com/nulayer/subexec]; it supports logging for +stdout+ and +stderr+
  class Cmd
  
    class_attribute :subexec_options
    self.subexec_options = {}
    
    # +Subexec+ instance returned by the execution
    attr_reader :subexec

    # It runs the supplied command, logging 
    #
    # ### Args
    #
    # * *stdout*: a valid +Subexec+ value for stdout logging; if +:dev_null+ discards the output. Defaults to +:dev_null+
    # * *stderr*: a valid +Subexec+ value for stderr logging; if +:dev_null+ discards the output. Defaults to +:dev_null+
    #
    # ### Returns
    #
    # The executed +Subexec+ instance
    def run(stdout = :dev_null, stderr = :dev_null)
      stdout = %w(/dev/null w) if stdout == :dev_null
      stderr = %w(/dev/null w) if stderr == :dev_null

      File.write(stdout[0], "#{cmd}\n\n") if stdout.is_a?(Array) && stdout[1] == 'a'

      @subexec = Subexec.run cmd, subexec_options.merge(stdout: stdout, stderr: stderr)
    end

    # As Media::Cmd#run, but raises a Media::Error if the command execution fails
    def run!(stdout = :dev_null, stderr = :dev_null)
      run(stdout, stderr)
      raise Error.new('command failed', cmd: cmd, exitstatus: exitstatus, output: subexec.output, stdout: stdout, stderr: stderr) if exitstatus != 0
    end

    # Returns the exit status of the last execution (+nil+ if not executed)
    def exitstatus
      subexec.try(:exitstatus)
    end

    # the <tt>@cmd</tt> instance variable (sets it calling Media::Cmd#cmd! if not yet set)
    def cmd
      @cmd ||= cmd!
    end

    # alias to Media::Cmd#cmd
    alias to_s cmd

    # The command string
    def cmd!
      ''
    end

  end
end