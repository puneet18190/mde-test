# ### Description
#
# Contains the actions used in autocomplete
#
# ### Models used
#
# * Tag
# * Tagging
#
class TagsController < ApplicationController
  
  # ### Description
  #
  # Gets the list of the most popular tags that match the inserted keyword (paramster +term+). See Tag.get_tags_for_autocomplete
  #
  # ### Mode
  #
  # Json
  #
  def get_list
    @tags = Tag.get_tags_for_autocomplete(current_user, params[:term], params[:item])
    render :json => @tags
  end
  
  # ### Description
  #
  # Checks if a specific tag is present in the database (if yes, the tag box gets colored)
  #
  # ### Mode
  #
  # Json
  #
  def check_presence
    render :json => {:ok => Tag.where(:word => params[:word]).any?}
  end
  
end
