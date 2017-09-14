require 'media'
require 'env_relative_path'

module Media

  # Provides support for instance- and/or thread-relative logging
  module Logging

    # Filename of the stdout log
    STDOUT_LOG = 'stdout.log'
    # Filename of the stderr log
    STDERR_LOG = 'stderr.log'

    include EnvRelativePath

    # Remove the log folder
    def self.remove_folder!
      FileUtils.rm_rf Rails.root.join('log', to_s.split('::').take(1).join('::').underscore).to_s
    end

    module ClassMethods
      # Returns the class log folder which will contain the instances log folders.
      # The naming of the folder is elaborated considering the first 4 nestings (3 if +folder_name+ is supplied) of the module in which the method is called - see {Examples}[rdoc-label:method-i-log_folder-label-Examples]
      #
      # ### Args
      #
      # * *folder_name*: if present, it will be used instead of the name of the module included - see {Examples}[rdoc-label:method-i-log_folder-label-Examples]
      #
      # ### Examples
      #
      #  Media::A::B::C.log_folder        #=> "/path/to/app/log/media/a/b/c"
      #  Media::A::B::C.log_folder('asd') #=> "/path/to/app/log/media/a/b/asd"
      def log_folder(folder_name = nil)
        nesting = folder_name ? 3 : 4
        log_folder_const = self.to_s.split('::').take(nesting).join('::').underscore
        
        env_relative_path Rails.root, 'log', log_folder_const, folder_name.to_s
      end
    end
    
    module InstanceMethods
      # Create the instance log folder (calling Media::Logging::InstanceMethods#log_folder)
      #
      # ### Args
      #
      # * *folder_name*: it is passed to the Media::Logging::InstanceMethods#log_folder call
      def create_log_folder(folder_name = nil)
        self.thread_relative_log_folder = log_folder(folder_name)
        FileUtils.mkdir_p(thread_relative_log_folder).first
      end

      # instance-/thread-relative/custom named log folder which will be located inside the class log folder
      def log_folder(folder_name = nil)
        @log_folder || thread_relative_log_folder || (
          folder_name ||= "#{Time.now.utc.strftime("%Y-%m-%d_%H-%M-%S")}_#{::Thread.current.object_id}"
          File.join self.class.log_folder, folder_name
        )
      end
      
      # instance stdout log file; it takes optionally a +prefix+ which will be prefixed to the filename
      def stdout_log(prefix = nil)
        File.join log_folder, (prefix ? "#{prefix}.#{STDOUT_LOG}" : STDOUT_LOG)
      end

      # instance stderr log file; it takes optionally a +prefix+ which will be prefixed to the filename
      def stderr_log(prefix = nil)
        File.join log_folder, (prefix ? "#{prefix}.#{STDERR_LOG}" : STDERR_LOG)
      end

      # stdout and stderr logs ready for be passed to a Media::Cmd#run; +prefix+ will be passed to Media::Logging::InstanceMethods#stdout_log and Media::Logging::InstanceMethods#stderr_log
      def logs(prefix = nil)
        [%W(#{stdout_log(prefix)} a), %W(#{stderr_log(prefix)} a)]
      end

      private
      # thread-relative log folder name
      def thread_relative_log_folder_name
        if Thread.current == Thread.main
          :@log_folder
        else
          :"@log_folder_for_thread_#{Thread.current.object_id}"
        end
      end

      # thread-relative log folder getter
      def thread_relative_log_folder
        instance_variable_get thread_relative_log_folder_name
      end

      # thread-relative log folder setter
      def thread_relative_log_folder=(thread_relative_log_folder)
        instance_variable_set thread_relative_log_folder_name, thread_relative_log_folder
      end
    end

    # The modules which include this module will include EnvRelativePath too
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, EnvRelativePath
      receiver.send :include, InstanceMethods
    end

  end
end
