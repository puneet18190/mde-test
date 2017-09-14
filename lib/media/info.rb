require 'media'
require 'media/error'
require 'media/cmd/avprobe'
require 'media/similar_durations'

module Media

  # Provides informations about media files parsing the output of +avprobe+
  class Info

    # Regular expression for media duration matching
    DURATION_REGEX       = /^  Duration: (?<hours>\d{2,}):(?<minutes>\d\d):(?<seconds>\d\d\.\d\d)/
    # Supported stream types
    STREAMS              = [:video, :audio]
    # Regular expression for stream infos matching
    STREAMS_REGEX_FORMAT = '^    Stream #0\.\d+.*?: %s.*?: (.*)$'
    # Regular expression for the codecs matching
    CODEC_MATCH_REGEX    = /^(?<codec>\w+)/
    # Regular expression for bitrates matching
    BITRATE_MATCH_REGEX  = /, (?<bitrate>\d+) kb\/s(,|$)/
    # Regular expression for video sizes matching
    SIZES_MATCH_REGEX    = /, (?<width>\w+)x(?<height>\w+)( \[PAR \w+:\w+ DAR \w+:\w+\])?(,|$)/
    # Maximum difference of duration between the generated videos (if exceeded two medias are considered different)
    DURATION_THRESHOLD   = CONFIG.duration_threshold
    # Maximum difference of bitrate between the generated videos (if exceeded two medias are considered different)
    BITRATE_THRESHOLD    = 5

    include Media::SimilarDurations

    # Supplied path to the media file
    attr_reader :path

    # ### Args
    # 
    # * *path*: path to a media file
    # * *raise_if_invalid*: if +true+, raises a Media::Error when +avprobe+ doesn't consider the supplied media valid
    def initialize(path, raise_if_invalid = true)
      @path      = File.expand_path path
      @cmd       = Cmd::Avprobe.new(path)
      @output    = @cmd.run.output
      exitstatus = @cmd.exitstatus

      if exitstatus != 0
        if raise_if_invalid
          raise Error.new('avprobe failed', path: @path, cmd: @cmd, exitstatus: exitstatus)
        else
          @invalid = true
        end
      end
    end

    # +true+ if the media is valid, +false+ otherwise
    def valid?
      not @invalid
    end

    # Compares two media info hashes (should be retrieved using Media::Info#to_hash), returning +true+ if they are considered similar, +false+ otherwise
    #
    # ### Args
    #
    # * *other_infos_hash*: hash of another media file infos
    # * *ignore_bitrate*: when +true+ the bitrates are not compared
    #
    # ### Examples
    #
    #  Media::Info.new('video1.webm').similar_to? Media::Info.new('video1.webm').to_hash #=> true
    #  Media::Info.new('video1.webm').similar_to? Media::Info.new('video1.mp4').to_hash  #=> false
    def similar_to?(other_infos_hash, ignore_bitrate = false)
      return false unless other_infos_hash.is_a?(Hash)

      infos_hash = to_hash.reject{ |k,_| k == :path }
      return false if (infos_hash[:duration].blank? && other_infos_hash[:duration].present?) || (infos_hash[:duration].present? && other_infos_hash[:duration].blank?)
      return false unless similar_durations?(infos_hash[:duration], other_infos_hash[:duration])

      streams, other_streams = infos_hash[:streams], other_infos_hash[:streams]
      return false unless streams.keys.sort == other_streams.keys.sort

      return true if ignore_bitrate

      streams.each do |k, _streams|
        _streams.each_with_index do |stream, i|
          other_stream = other_infos_hash[:streams][k][i]
          bitrate, other_bitrate = stream[:bitrate], other_stream[:bitrate]

          return false unless stream.reject{ |k,_| k == :bitrate } == other_stream.reject{ |k,_| k == :bitrate }
          next if !bitrate && !other_bitrate
          return false if (bitrate && !other_bitrate) || (!bitrate && other_bitrate)
          return false unless (bitrate-BITRATE_THRESHOLD..bitrate+BITRATE_THRESHOLD).include? other_bitrate
        end
      end

      true
    end

    # Returns the media duration (in seconds) when the media is valid, +nil+ otherwise
    def duration
      return nil unless valid?

      matches = @output.match DURATION_REGEX
      hours, minutes, seconds = matches[:hours], matches[:minutes], matches[:seconds]

      unless hours and minutes and seconds
        raise Error.new('not parsable duration', cmd: @cmd, output: @output)
      end

      hours_to_seconds   = hours.to_i   * 3600
      minutes_to_seconds = minutes.to_i * 60

      seconds.to_f + hours_to_seconds + minutes_to_seconds
    end

    # Returns an hash containing the streams infos when the media is valid, +nil+ otherwise
    def streams
      return nil unless valid?

      # The streams infos parsing is a bit tricky: from an input like this
      #
      #     Stream #0.0: Video: h264 (Main), yuv420p, 320x240, 445 kb/s, 29.97 tbr, 1k tbn, 59.94 tbc
      #     Stream #0.1: Audio: aac, 44100 Hz, mono, s16, 78 kb/s
      #
      # I need to obtain an output like this:
      #
      #     {
      #       :video => { 
      #         [ { codec: 'h264', bitrate: 445 } ]
      #       },
      #       :audio => {
      #         [ { codec: 'aac', bitrate: 78 } ]
      #       }
      #     }
      @streams ||=
        {}.tap do |streams|
          STREAMS.each do |stream_type|
            # Scan example:
            #   '    Stream #0.0: Video(eng): h264 (Main), yuv420p, 320x240, 445 kb/s, 29.97 tbr, 1k tbn, 59.94 tbc' =>
            #   [["    Stream #0.0: Video(eng): ", "h264 (Main), yuv420p, 320x240, 445 kb/s, 29.97 tbr, 1k tbn, 59.94 tbc"]
            s = @output.scan Regexp.new(STREAMS_REGEX_FORMAT % stream_type.to_s.capitalize)

            streams[stream_type] = s.map do |scan_data|
              send(:"parse_#{stream_type}_stream", scan_data)
            end
          end
        end
    end

    # Returns an array containing the video streams infos when the media is valid, +nil+ otherwise
    def video_streams
      return nil unless valid?

      streams[:video]
    end

    # Returns an array containing the audio streams infos when the media is valid, +nil+ otherwise
    def audio_streams
      return nil unless valid?

      streams[:audio]
    end

    # Returns an hash with the media infos when the media is valid, +nil+ otherwise
    def to_hash
      return nil unless valid?
      
      { path: path, duration: duration, streams: streams }
    end

    private
    # Used by Media::Info#streams, processes the video streams parsing in order to return the infos
    def parse_video_stream(scan_data)
      stream_data = scan_data[0]

      codec_match   = stream_data.match CODEC_MATCH_REGEX
      sizes_match   = stream_data.match SIZES_MATCH_REGEX
      bitrate_match = stream_data.match BITRATE_MATCH_REGEX

      unless sizes_match
        raise Error.new('not parsable video sizes', cmd: @cmd, output: @output)
      end

      { codec:     codec_match.try(:[], :codec  ),
        width:     sizes_match.try(:[], :width  ).try(:to_i),
        height:    sizes_match.try(:[], :height ).try(:to_i),
        bitrate: bitrate_match.try(:[], :bitrate).try(:to_i)  }
    end

    # Used by Media::Info#streams, processes the audio streams parsing in order to return the infos
    def parse_audio_stream(scan_data)
      stream_data = scan_data[0]

      codec_match   = stream_data.match CODEC_MATCH_REGEX
      bitrate_match = stream_data.match BITRATE_MATCH_REGEX

      { codec:     codec_match.try(:[], :codec  ),
        bitrate: bitrate_match.try(:[], :bitrate).try(:to_i)  }
    end

  end
end