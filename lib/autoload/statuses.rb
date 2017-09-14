# Keywords for statuses of lessons and elements; with the word +item+ below we refere to both lessons and media elements. See Lesson#set_status and MediaElement#set_status
module Statuses
  
  # The field +is_public+ is +false+, and the item belongs to the user
  PRIVATE = 'private'
  
  # The field +is_public+ is +true+, and the user has a link to the item
  LINKED = 'linked'
  
  # The lesson has the field +copied_not_modified+ set as +true+
  COPIED = 'copied'
  
  # The lesson has the field +is_public+ set as +true+ and it belongs to the user
  SHARED = 'shared'
  
  # The item has the field +is_public+ set as +true+ and it's not linked by the user
  PUBLIC = 'public'
  
  # Set of available statuses for lessons
  LESSONS_SET = [PRIVATE, LINKED, COPIED, SHARED, PUBLIC]
  
  # Set of available statuses for elements
  MEDIA_ELEMENTS_SET = [PRIVATE, LINKED, PUBLIC]
  
end
