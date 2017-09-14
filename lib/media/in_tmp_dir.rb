require 'media'

module Media

  # Provides methods useful dealing with temporary folders:
  #
  # * Media::InTmpDir#in_tmp_dir takes a block in which you can access to a temporary folder path set to <tt>@tmp_dir</tt>
  # * Media::InTmpDir#tmp_path(path) returns the supplied +path+ relative to <tt>@tmp_dir</tt>
  #
  # ### Example
  #
  #  class VideoProcessing
  #    include Media::InTmpDir
  #    def process
  #      puts @tmp_path               #=> nil
  #      in_tmp_dir do
  #        puts @tmp_path             #=> "/tmp/rrgiun39fsf9jwnwq3r"
  #        puts tmp_path('video.mp4') #=> "/tmp/rrgiun39fsf9jwnwq3r/video.mp4"
  #      end
  #      puts @tmp_path               #=> nil
  #    end
  #  end
  #
  module InTmpDir
  
    # Takes a block in which you can access to a temporary folder path set to <tt>@tmp_dir</tt>. It takes care of clearing <tt>@tmp_dir</tt> after the block execution or if an error occurs
    def in_tmp_dir
      Dir.mktmpdir(Rails.application.config.tempfiles_prefix.call) do |dir|
        @tmp_dir = dir
        yield
      end
    ensure
      @tmp_dir = nil
    end

    # Returns the supplied +path+ relative to <tt>@tmp_dir</tt>
    def tmp_path(path)
      raise Error.new('@tmp_dir must be present', path: path) unless @tmp_dir
      File.join(@tmp_dir, path)
    end

  end
end