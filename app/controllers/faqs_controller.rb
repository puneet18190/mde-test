# ### Description
#
# Contains the FAQS, organized into cathegories
#
class FaqsController < ApplicationController
  
  before_filter :initialize_layout
  layout 'faqs'
  
  # Index of all the FAQS
  def index
    @lessons_faqs = t('faqs.lessons.contents')
    @media_elements_faqs = t('faqs.media_elements.contents')
    @virtual_classroom_faqs = t('faqs.virtual_classroom.contents')
    @profile_faqs = t('faqs.profile.contents')
  end
  
  # A FAQ about lessons
  def lessons
    @answer = t('faqs.lessons.contents')[params[:num].to_i - 1]
    if !correct_integer?(params[:num]) || @answer.nil?
      render_not_found
      return
    end
  end
  
  # A FAQ about media elements
  def media_elements
    @answer = t('faqs.media_elements.contents')[params[:num].to_i - 1]
    if !correct_integer?(params[:num]) || @answer.nil?
      render_not_found
      return
    end
  end
  
  # A FAQ about the Virtual Classroom
  def virtual_classroom
    @answer = t('faqs.virtual_classroom.contents')[params[:num].to_i - 1]
    if !correct_integer?(params[:num]) || @answer.nil?
      render_not_found
      return
    end
  end
  
  # A FAQ about user's profile
  def profile
    @answer = t('faqs.profile.contents')[params[:num].to_i - 1]
    if !correct_integer?(params[:num]) || @answer.nil?
      render_not_found
      return
    end
  end
  
  private
  
  # Renders not found page
  def render_not_found
    render text: '404 Not found', :status => :not_found, layout: false
  end
  
end
