require 'media'
require 'media/audio'
require 'media/audio/editing'

module Media
  module Audio
    module Editing
      
      # Module that contains parameters converter for the audio editor (see Audio, AudioEditorController)
      module Parameters
        
        # This method doesn't check that the parameters are valid; it takes as input either the basic hash or the full one, and calculates the total time
        def total_prototype_time(hash)
          return 0 if !hash[:components].instance_of?(Array)
          sum = 0
          hash[:components].each do |component|
            return 0 if !component[:to].kind_of?(Integer) || !component[:from].kind_of?(Integer)
            sum += component[:to]
            sum -= component[:from]
          end
          sum
        end
        
        # This method uses Media::Audio::Editing::Parameters#convert_parameters to validate the parameters, and then converts them into a primitive hash that contains only IDs instead than objects: now the parameters are ready to be passed to the editor
        def convert_to_primitive_parameters(hash, user_id)
          resp = convert_parameters(hash, user_id)
          return nil if resp.nil?
          resp[:initial_audio] = resp[:initial_audio].id if resp[:initial_audio]
          resp[:components].each do |component|
            component[:audio] = component[:audio].id
          end
          resp
        end
        
        # ### Description
        #
        # Validates and converts the parameters. See the code for further details about the validations achieved. The product is in the following format:
        # * an initial parameter, 'initial_audio'
        # * then an ordered array of components:
        #   * each component is a hash, with a key called :type
        #   * if the type is 'video', there is an object of kind VIDEO associated to the key :video
        #   * if the type is 'image', there is an object of kind IMAGE associated to the key :image
        #
        # ### Usage
        #
        #  {
        #    :initial_audio => OBJECT OF TYPE AUDIO or NIL,
        #    :components => [
        #      {
        #        :audio => OBJECT OF TYPE AUDio,
        #        :from => 12,
        #        :to => 24
        #      },
        #      {
        #        etc...
        #      }
        #    ]
        #  }
        #
        def convert_parameters(hash, user_id)
          
          # check if initial audio is correctly declared (it can be nil or integer)
          return nil if !hash.instance_of?(Hash) || !hash.has_key?(:initial_audio_id)
          return nil if !hash[:initial_audio_id].nil? && !hash[:initial_audio_id].kind_of?(Integer)
          
          # initialize empty hash
          resp_hash = HashWithIndifferentAccess.new
          
          # if initial audio is present, I validate that it exists and is accessible from the user
          if hash[:initial_audio_id].nil?
            initial_audio = nil
          else
            initial_audio = get_media_element_from_hash(hash, :initial_audio_id, user_id, 'Audio')
            return nil if initial_audio.nil? || initial_audio.is_public
          end
          
          # insert initial audio (which is nil if the audio does not overwrite any previous one)
          resp_hash[:initial_audio] = initial_audio
          
          # there must be a list of components
          return nil if !hash[:components].instance_of?(Array) || hash[:components].empty?
          
          # initialize empty components
          resp_hash[:components] = []
          
          # for each component I validate it and add it to the HASH
          hash[:components].each do |p|
            return nil if !p.instance_of?(Hash)
            c = extract_component(p, user_id)
            return nil if c.nil?
            resp_hash[:components] << c
          end
          
          resp_hash
        end
        
        # Using Media::Audio::Editing::Parameters#get_media_element_from_hash, it validates that the audio exists and is accessible from the user, then that +from+ and +to+ are correct
        def extract_component(component, user_id)
          audio = get_media_element_from_hash(component, :audio_id, user_id, 'Audio')
          return nil if audio.nil?
          return nil if !component[:from].kind_of?(Integer) || !component[:to].kind_of?(Integer)
          return nil if component[:from] < 0 || component[:to] > audio.min_duration || component[:from] >= component[:to]
          HashWithIndifferentAccess.new audio: audio,
                                        from:  component[:from],
                                        to:    component[:to]
        end
        
        # Used in Media::Audio::Editing::Parameters#extract_component
        def get_media_element_from_hash(hash, key, user_id, my_sti_type)
          hash[key].kind_of?(Integer) ? MediaElement.extract(hash[key], user_id, my_sti_type) : nil
        end
        
      end
    end
  end
end
