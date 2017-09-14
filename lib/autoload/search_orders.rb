# Keywords for possible orders in the results of the search engine
module SearchOrders
  
  # Sort by descending +updated_at+
  UPDATED_AT = 'updated_at'
  
  # Sort by descending +created_at+
  CREATED_AT = 'created_at'
  
  # Sort by descending sum of likes (available only for lessons)
  LIKES = 'likes'
  
  # Sort by ascending title in alphabetical order
  TITLE = 'title'
  
  # List of orders available for lessons
  LESSONS_SET = [UPDATED_AT, LIKES, TITLE]
  
  # List of orders available for elements
  MEDIA_ELEMENTS_SET = [UPDATED_AT, TITLE]
  
  # List of orders available for documents
  DOCUMENTS_SET = [CREATED_AT, TITLE]
  
end
