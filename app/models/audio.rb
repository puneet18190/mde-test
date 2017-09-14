require 'media/audio/uploader'
require 'media/audio/editing/parameters'
require 'media/shared'

# ### Description
#
# This class inherits from MediaElement, and contains the specific methods needed for media elements of type +audio+. For methods shared by elements of type +audio+ and +video+, see Media::Shared.
# 
class Audio < MediaElement
  
  include Media::Shared
  include UrlTypes
  extend Media::Audio::Editing::Parameters
  
  # Instance of specific uploader for an audio
  UPLOADER = Media::Audio::Uploader
  
  # List of accepted extensions
  EXTENSION_WHITE_LIST = UPLOADER::EXTENSION_WHITE_LIST
  
  # Path for restoring the audio editor cache
  CACHE_RESTORE_PATH = '/audios/cache/restore'
  
  # Url of the thumb to be used in the section 'elements'
  THUMB_URL = '/assets/simbolo-audio.svg'

  EBOOK_FORMATS = UPLOADER::FORMATS + UPLOADER::VERSION_FORMATS.keys - [:thumb]
  
  # ### Description
  #
  # Returns the url for the audio in format +m4a+
  #
  # ### Returns
  #
  # An url.
  #
  # ### Usage
  #
  #   <audio>
  #     <source src="<%= audio.m4a_url %>" type="audio/mp4">
  #   </audio>
  #
  def m4a_url(url_type = nil)
    return nil unless converted

    url = media.try(:url, :m4a)

    return nil unless url

    url_by_url_type url, url_type
  end
  
  # ### Description
  #
  # Returns the url for the audio in format +ogg+
  #
  # ### Returns
  #
  # An url.
  #
  # ### Usage
  #
  #   <audio>
  #     <source src="<%= audio.ogg_url %>" type="audio/ogg">
  #   </audio>
  #
  def ogg_url(url_type = nil)
    return nil unless converted

    url = media.try(:url, :ogg)

    return nil unless url

    url_by_url_type url, url_type
  end
  
  # ### Description
  #
  # Returns the url of the thumb image used in the section "elements" (a musical note on gray bottom). If the audio is not converted, returns the animated gif from Audio#placeholder_url with +type+=+thumb+.
  #
  # ### Returns
  #
  # An url.
  #
  # ### Usage
  #
  #   <%= image_tag audio.thumb_url %>
  #
  def thumb_url(url_type = nil)
    converted ? THUMB_URL : placeholder_url(:thumb, url_type)
  end
  
  # ### Description
  #
  # Returns the url of the placeholder used in case the audio is being converted (an animated gif).
  #
  # ### Args
  #
  # * *type*: the type of placeholder required: it can be
  #   * +:thumb+: used in the expanded media element
  #   * +:lesson_viewer+: used in the lesson viewer
  #
  # ### Returns
  #
  # An url.
  #
  # ### Usage
  #
  #   <% if audio.converted? %>
  #     <%= render :partial => 'shared/players/custom/audio', :locals => {:audio => audio} %>
  #   <% else %>
  #     <%= image_tag audio.placeholder_url(:lesson_viewer) %>
  #   <% end %>
  #
  def placeholder_url(type, url_type = nil)
    url = "/assets/placeholders/audio_#{type}.gif"
    
    url_by_url_type url, url_type
  end
  
  # ### Description
  #
  # Returns the float duration in seconds of the m4a track;
  #
  # ### Returns
  #
  # A float.
  #
  def m4a_duration
    metadata.m4a_duration
  end
  
  # ### Description
  #
  # Returns the float duration in seconds of the ogg track;
  #
  # ### Returns
  #
  # A float.
  #
  def ogg_duration
    metadata.ogg_duration
  end
  
  # ### Description
  #
  # Sets the float duration in seconds of the m4a track;
  #
  # ### Args
  #
  # * *m4a_duration*: the duration to be set
  #
  def m4a_duration=(m4a_duration)
    metadata.m4a_duration = m4a_duration
  end
  
  # ### Description
  #
  # Sets the float duration in seconds of the ogg track;
  #
  # ### Args
  #
  # * *ogg_duration*: the duration to be set
  #
  def ogg_duration=(ogg_duration)
    metadata.ogg_duration = ogg_duration
  end
  
  # ### Description
  #
  # Returns the lower integer approximation of the minimum between +ogg_duration+ and +m4a_duration+. This is necessary to insert in the html players an integer duration in seconds that can be used without risks.
  #
  # ### Returns
  #
  # An integer.
  #
  # ### Usage
  #
  #   <div class="audioPlayer _instance_of_player" data-media-type="audio" data-initialized="false" data-duration="<%= audio.min_duration %>">
  #
  def min_duration
    [m4a_duration, ogg_duration].map(&:to_i).min
  end
  
end
