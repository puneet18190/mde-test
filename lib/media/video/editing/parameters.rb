require 'media'
require 'media/video'
require 'media/video/editing'

module Media
  module Video
    module Editing
      
      # Module that contains parameters converter for the video editor (see Video, VideoEditorController)
      module Parameters
        
        # Keyword for a video component
        VIDEO_COMPONENT = 'video'
        
        # Keyword for a text component
        TEXT_COMPONENT = 'text'
        
        # Keyword for an image component
        IMAGE_COMPONENT = 'image'
        
        # List of keywords of possible video components
        COMPONENTS = [VIDEO_COMPONENT, TEXT_COMPONENT, IMAGE_COMPONENT]
        
        # This method doesn't check that the parameters are valid; it takes as input either the basic hash or the full one, and calculates the total time
        def total_prototype_time(hash)
          return 0 if !hash[:components].instance_of?(Array)
          sum = 0
          hash[:components].each do |component|
            case component[:type]
              when VIDEO_COMPONENT
                return 0 if !component[:to].kind_of?(Integer) || !component[:from].kind_of?(Integer)
                sum += component[:to]
                sum -= component[:from]
              when IMAGE_COMPONENT
                return 0 if !component[:duration].kind_of?(Integer)
                sum += component[:duration]
              when TEXT_COMPONENT
                return 0 if !component[:duration].kind_of?(Integer)
                sum += component[:duration]
            else
              return 0
            end
          end
          if hash[:components].any?
            sum += (hash[:components].length - 1)
          end
          sum
        end
        
        # This method uses Media::Video::Editing::Parameters#convert_parameters to validate the parameters, and then converts them into a primitive hash that contains only IDs instead than objects: now the parameters are ready to be passed to the editor
        def convert_to_primitive_parameters(hash, user_id)
          resp = convert_parameters(hash, user_id)
          return nil if resp.nil?
          resp[:initial_video] = resp[:initial_video].id if resp[:initial_video]
          resp[:audio_track] = resp[:audio_track].id if resp[:audio_track]
          resp[:components].each do |component|
            component[:video] = component[:video].id if component[:video]
            component[:image] = component[:image].id if component[:image]
            if component[:type] == TEXT_COMPONENT
              component[:content] = component[:content].gsub('<br/>', "\n")
              component[:background_color] = ::SETTINGS['colors'][component[:background_color]]['code']
              component[:text_color] = ::SETTINGS['colors'][component[:text_color]]['code']
            end
          end
          resp
        end
        
        # ### Description
        #
        # Validates and converts the parameters. See the code for further details about the validations achieved. The product is in the following format:
        # * two initial parameters, 'initial_video' and 'audio_track'
        # * then an ordered array of components:
        #   * each component is a hash, with a key called :type
        #   * if the type is 'video', there is an object of kind VIDEO associated to the key :video
        #   * if the type is 'image', there is an object of kind IMAGE associated to the key :image
        #
        # ### Usage
        #
        #  {
        #    :initial_video => OBJECT OF TYPE VIDEO or NIL,
        #    :audio_track => OBJECT OF TYPE AUDIO or NIL,
        #    :components => [
        #      {
        #        :type => Video::VIDEO_COMPONENT,
        #        :video => OBJECT OF TYPE VIDEO,
        #        :from => 12,
        #        :to => 24
        #      },
        #      {
        #        :type => Video::TEXT_COMPONENT,
        #        :content => 'Titolo titolo titolo',
        #        :duration => 14,
        #        :background_color => 'red',
        #        :text_color => 'white'
        #      },
        #      {
        #        :type => Video::IMAGE_COMPONENT,
        #        :image => OBJECT OF TYPE IMAGE,
        #        :duration => 2
        #      }
        #    ]
        #  }
        #
        def convert_parameters(hash, user_id)
          
          # check if initial video and audio track are correctly declared (they can be nil or integer)
          return nil if !hash.instance_of?(Hash) || !hash.has_key?(:initial_video_id) || !hash.has_key?(:audio_id)
          return nil if !hash[:initial_video_id].nil? && !hash[:initial_video_id].kind_of?(Integer)
          return nil if !hash[:audio_id].nil? && !hash[:audio_id].kind_of?(Integer)
          
          # initialize empty hash
          resp_hash = HashWithIndifferentAccess.new
          
          # if initial video is present, I validate that it exists and is accessible from the user
          if hash[:initial_video_id].nil?
            initial_video = nil
          else
            initial_video = get_media_element_from_hash(hash, :initial_video_id, user_id, 'Video')
            return nil if initial_video.nil? || initial_video.is_public
          end
          
          # insert initial video (which is nil if the video does not overwrite any previous one)
          resp_hash[:initial_video] = initial_video
          
          # if audio track is present, I validate that it exists and is accessible from the user
          if hash[:audio_id].nil?
            audio_track = nil
          else
            audio_track = get_media_element_from_hash(hash, :audio_id, user_id, 'Audio')
            return nil if audio_track.nil?
          end
          
          # insert audio track (which is nil if the user wants to keep the original audio of each component)
          resp_hash[:audio_track] = audio_track
          
          # there must be a list of components
          return nil if !hash[:components].instance_of?(Array) || hash[:components].empty?
          
          # initialize empty components
          resp_hash[:components] = []
          
          # for each component I validate it and add it to the HASH
          hash[:components].each do |p|
            return nil if !p.instance_of?(Hash) || !COMPONENTS.include?(p[:type])
            case p[:type]
              when VIDEO_COMPONENT
                c = extract_video_component(p, user_id)
                return nil if c.nil?
                resp_hash[:components] << c
              when TEXT_COMPONENT
                c = extract_text_component(p)
                return nil if c.nil?
                resp_hash[:components] << c
              when IMAGE_COMPONENT
                c = extract_image_component(p, user_id)
                return nil if c.nil?
                resp_hash[:components] << c
            end
          end
          
          resp_hash
        end
        
        # Using Media::Video::Editing::Parameters#get_media_element_from_hash, it validates that the image exists and is accessible from the user, then that +duration+ is correct
        def extract_image_component(component, user_id)
          image = get_media_element_from_hash(component, :image_id, user_id, 'Image')
          return nil if image.nil?
          return nil if !component[:duration].kind_of?(Integer) || component[:duration] < 1
          {
            :type => IMAGE_COMPONENT,
            :image => image,
            :duration => component[:duration]
          }
        end
        
        # Using Media::Video::Editing::Parameters#get_media_element_from_hash, it validates that the video exists and is accessible from the user, then that +from+ and +to+ are correct
        def extract_video_component(component, user_id)
          video = get_media_element_from_hash(component, :video_id, user_id, 'Video')
          return nil if video.nil?
          return nil if !component[:from].kind_of?(Integer) || !component[:to].kind_of?(Integer)
          return nil if component[:from] < 0 || component[:to] > video.min_duration || component[:from] >= component[:to]
          {
            :type => VIDEO_COMPONENT,
            :video => video,
            :from => component[:from],
            :to => component[:to]
          }
        end
        
        # It validates that +content+, +colors+ and +duration+ are all correct
        def extract_text_component(component)
          return nil if !component.has_key?(:content) || !component[:duration].kind_of?(Integer) || component[:duration] < 1
          return nil if !::SETTINGS['colors'].has_key?(component[:background_color]) || !::SETTINGS['colors'].has_key?(component[:text_color])
          {
            :type => TEXT_COMPONENT,
            :content => component[:content].to_s,
            :duration => component[:duration],
            :background_color => component[:background_color],
            :text_color => component[:text_color]
          }
        end
        
        # Used in Media::Video::Editing::Parameters#extract_video_component, Media::Video::Editing::Parameters#extract_image_component, Media::Video::Editing::Parameters#extract_text_component
        def get_media_element_from_hash(hash, key, user_id, my_sti_type)
          hash[key].kind_of?(Integer) ? MediaElement.extract(hash[key], user_id, my_sti_type) : nil
        end
        
      end
    end
  end
end
