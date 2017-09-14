require 'media'
require 'media/video'
require 'media/video/editing'
require 'media/video/editing/cmd'
require 'media/video/editing/cmd/avconv'
require 'media/error'

module Media
  module Video
    module Editing
      class Cmd
        # CLI for video conversions
        class Conversion < Cmd::Avconv
  
          # Output video width
          OW  = AVCONV_OUTPUT_WIDTH
          # Output video height
          OH  = AVCONV_OUTPUT_HEIGHT
          # Output video aspect ratio
          OAR = AVCONV_OUTPUT_ASPECT_RATIO

          self.formats        = FORMATS
          self.codecs         = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).codecs] } ]
          self.output_qa      = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).qa] } ] 
          self.output_threads = Hash[ FORMATS.map{ |f| [f, CONFIG.avtools.avconv.video.formats.send(f).threads] } ]

          # Creates a new Media::Video::Editing::Cmd::Conversion instance
          #
          # ### Arguments
          #
          # * *input_file*: the path of file to be converted
          # * *output_file*: the output path
          # * *format*: the output format
          # * *input_file_info* _optional_: the Media::Info of the input file
          def initialize(input_file, output_file, format, input_file_info = nil)
            super([input_file], output_file, format)
  
            @input_file_info = input_file_info || Info.new(input_file)
            if vstreams.blank?
              raise Error.new( 'at least one video stream must be present', 
                               input_file: input_file, output_file: output_file, format: format, input_file_info: input_file_info )
            end
            
            output_options [ vcodec, acodec, vmap, amap, vfilters, achannels, ar ]
          end
  
          private
        
          # avconv video filters option (+-vf+)
          #
          # The goal here is to resize the input video keeping the original ratio to a size 
          # which fills in OUTPUT_WIDTH and OUTPUT_HEIGHT values, and then eventually crop 
          # the parts of the input video which exceed in order to obtain an output video of
          # OUTPUT_WIDTH and OUTPUT_HEIGHT sizes.
          #
          # In order to reach our goal, we apply two avconv filters; in order to understand 
          # how they work, you should read carefully AVConv manual before (<tt>man avconv</tt>),
          # expecially sections 'EXPRESSION EVALUATION' and 'VIDEO FILTERS'.
          # 
          # We apply two filters:
          #
          #  scale:
          #    output width:
          #      lt(iw/ih\,#{OAR})    #=> if input_width/input_height is less than the output aspect ratio
          #      *#{OW}               #=> then resize width to OUTPUT_WIDTH
          #      +gte(iw/ih\\,#{OAR}) #=> else if input_width/input_height is greater than or equal to the output aspect ratio
          #      *-1                  #=> then resize width to a value which maintains the aspect ratio of the input video
          #    output height:
          #      lt(iw/ih\,#{OAR})    #=> if input_width/input_height is less than the output aspect ratio
          #      *-1                  #=> then resize height to a value which maintains the aspect ratio of the input video
          #      +gte(iw/ih\\,#{OAR}) #=> else if input_width/input_height is greater than or equal to the output aspect ratio
          #      *#{OH}               #=> then resize height to OUTPUT_HEIGHT
          #  crop:
          #    output width and output height:
          #      #{OW}:#{OH}         #=> set respectively equal to OUTPUT_WIDTH and OUTPUT_HEIGHT
          #    crop x and crop y:
          #      (iw-OW)/2:(ih-OH)/2 #=> sets the position of the top-left corner of the output in order to center the video
          def vfilters
            %Q[-vf 'scale=lt(iw/ih\\,#{OAR})*#{OW}+gte(iw/ih\\,#{OAR})*-1:lt(iw/ih\\,#{OAR})*-1+gte(iw/ih\\,#{OAR})*#{OH},crop=#{OW}:#{OH}:(iw-ow)/2:(ih-oh)/2']
          end
  
          # input video streams (not used by the command)
          def vstreams
            @input_file_info.video_streams
          end
  
          # input audio streams (not used by the command)
          def astreams
            @input_file_info.audio_streams
          end
  
          # input videos filtering
          def vmap
            '-map 0:v:0'
          end
  
          # input audios filtering
          def amap
            astreams.present? ? '-map 0:a:0' : nil
          end
          
        end
      end
    end
  end
end
