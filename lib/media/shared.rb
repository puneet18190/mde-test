require 'media'

module Media

  # Included in both Audio and Video models
  module Shared
    
    # Types of media model creation
    CREATION_MODES = [:uploaded, :composed]

    # Types of media model creation
    UPLOADED, COMPOSED = CREATION_MODES

    module InstanceMethods
      # Returns +true+ if the model was created with an upload action, otherwise +false+
      def uploaded?
        metadata.creation_mode == UPLOADED
      end

      # Returns +true+ if the model was created with a composing action, otherwise +false+
      def composed?
        metadata.creation_mode == COMPOSED
      end

      # Returns +true+ if the model has already been modified at least one time, otherwise +false+
      def modified?
        created_at != updated_at
      end

      # Media attribute getter; returns the media instance associated if present (either an instance of Media::Video::Uploader or Media::Audio::Uploader), otherwise +nil+
      def media
        @media || ( 
          media = read_attribute(:media)
          media ? self.class::UPLOADER.new(self, :media, media) : nil 
        )
      end

      # Media attribute setter; passes the supplied value to the relative class uploader
      def media=(media)
        @media = write_attribute :media, (media.present? ? self.class::UPLOADER.new(self, :media, media) : nil)
      end

      # Reload the instance taking care of clearing instance variables
      def reload
        @media = @skip_conversion = @rename_media = nil
        super
      end

      # Clear the <tt>@media</tt> instance variable
      def reload_media
        @media = nil
      end

      # Media file size
      def size(format)
        media.try :size, format
      end

      # Return +true+ if the instance is set as +destroyable_even_if_not_converted+ or if it is not in a conversion state
      def cannot_destroy_while_converting
        destroyable_even_if_not_converted || converted?
      end

      # Prepare the record for the media overwriting operation
      def overwrite!
        # tags is not an attribute, so it doesn't result in the changes; 
        # using taggings_tags that is not yet changed
        old_fields = Hash[ self.changes.map{ |col, (old)| [col, old] } << ['tags', self.taggings_tags.map(&:word).join(', ')] ]
        self.metadata.old_fields = old_fields
        self.converted = false
        self.class.transaction do
          save!
          disable_lessons_containing_me
        end
      end

      private
      # Set the creation mode
      def set_creation_mode
        self.metadata.creation_mode = media.present? ? UPLOADED : COMPOSED
        true
      end

      # Execute the media validation
      def media_validation
        media.validation if media
      end

      # Execute the media upload/copy operation
      def upload_or_copy
        media.upload_or_copy if media
        true
      end

      # Clean the media folder
      def clean
        folder = media.try(:folder)
        FileUtils.rm_rf folder if folder
        true
      end
    end
    
    # Set Media::Shared::InstanceMethods#set_creation_mode as +before_create+, Media::Shared::InstanceMethods#upload_or_copy as +after_save+, Media::Shared::InstanceMethods#cannot_destroy_while_converting as +before_destroy+, Media::Shared::InstanceMethods#clean as +after_destroy+, Media::Shared::InstanceMethods#media_validation as +validate+ method
    #
    # Declares as +attr_accessor+:
    #
    # skip_conversion:: skips the conversion processing
    # rename_media:: allows the renaming of a media
    # composing:: whether the media is going to be conmposed or not
    # destroyable_even_if_not_converted:: allows the destroying of a media even if it is set as not converted
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods

      receiver.instance_eval do
        before_create  :set_creation_mode
        after_save     :upload_or_copy
        before_destroy :cannot_destroy_while_converting
        after_destroy  :clean

        validate :media_validation

        attr_accessor :skip_conversion, :rename_media, :composing, :destroyable_even_if_not_converted
      end
    end
  end
end
