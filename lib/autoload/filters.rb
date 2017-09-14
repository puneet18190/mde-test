# Keywords for filters of lessons and elements
module Filters
  
  # All lessons without any filter
  ALL_LESSONS = 'all_lessons'
  
  # Select only private lessons
  PRIVATE = 'private'
  
  # Select only public lessons
  PUBLIC = 'public'
  
  # Select only linked lessons
  LINKED = 'linked'
  
  # Select only lessons created by me
  ONLY_MINE = 'only_mine'
  
  # Select only lessons not created by me
  NOT_MINE = 'not_mine'
  
  # Select only lessons just copied
  COPIED = 'copied'
  
  # All elements without any filter
  ALL_MEDIA_ELEMENTS = 'all_media_elements'
  
  # Selects only elements of kind 'video'
  VIDEO = 'video'
  
  # Selects only elements of kind 'audio'
  AUDIO = 'audio'
  
  # Selects only elements of kind 'image'
  IMAGE = 'image'
  
  # Set of filters available for the section 'lessons'
  LESSONS_SET = [ALL_LESSONS, PRIVATE, PUBLIC, LINKED, ONLY_MINE, COPIED]
  
  # Set of filters available for the section 'elements'
  MEDIA_ELEMENTS_SET = [ALL_MEDIA_ELEMENTS, VIDEO, AUDIO, IMAGE]
  
  # Set of filters available for the search engine of lessons
  LESSONS_SEARCH_SET = [ALL_LESSONS, NOT_MINE, PUBLIC, ONLY_MINE]
  
  # Set of filters available for the search engine of elements
  MEDIA_ELEMENTS_SEARCH_SET = [ALL_MEDIA_ELEMENTS, VIDEO, AUDIO, IMAGE]
  
end
