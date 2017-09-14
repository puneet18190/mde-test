# Module of methods that return statistics, used in UsersController#statistics, Admin::DashboardController#index and Admin::UsersController#show
module Statistics
  
  class << self
    
    # The user necessary to scope all personal statistics
    attr_accessor :user
    
    # The first n lessons of the current user, ordered by the number of likes received
    def my_liked_lessons(first_n)
      Lesson.select('id, title, (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_count').where(:user_id => user.id).order('likes_count DESC, updated_at DESC').limit(first_n)
    end
    
    # The first n lessons liked by users in all the application
    def all_liked_lessons(first_n)
      Lesson.select('id, title, (SELECT COUNT (*) FROM likes WHERE likes.lesson_id = lessons.id) AS likes_count').order('likes_count DESC, updated_at DESC').limit(first_n)
    end
    
    # The first n users who received more likes
    def all_users_like(first_n)
      Like.joins(:lesson, :lesson => :user).group('users.id').select('users.id, users.name, users.surname, COUNT(*) AS likes_count').order('likes_count DESC, users.created_at DESC').limit(first_n)
    end
    
    # Lessons created by the current user, and copied by other users
    def my_copied_lessons
      Lesson.joins('INNER JOIN lessons AS parent_lessons ON (parent_lessons.id = lessons.parent_id)').where('lessons.user_id != ? AND parent_lessons.user_id = ?', user.id, user.id).count
    end
    
    # Lessons created by the current user (not including the lessons he copied and still not modified)
    def my_created_lessons
      Lesson.where(:user_id => user.id, :copied_not_modified => false).count
    end
    
    # Media Elements loaded or created by the current user (including the public ones, that might not be anymore in the user's section)
    def my_created_elements
      MediaElement.where(:user_id => user.id).count
    end
    
    # Number of bookmarks on my lessons
    def my_linked_lessons_count
      Bookmark.joins("INNER JOIN lessons ON (bookmarks.bookmarkable_type = 'Lesson' AND bookmarks.bookmarkable_id = lessons.id)").where(:lessons => {:user_id => user.id}).count
    end
    
    # The total amount of likes received by lessons created by the current user
    def my_likes_count
      Like.joins(:lesson).where(:lessons => {:user_id => user.id}).count
    end
    
    # The number of users in the application
    def all_users
      User.count
    end
    
    # The number of shared lessons in the application
    def all_shared_lessons
      Lesson.where(:is_public => true).count
    end
    
    # The number of shared media elements in the application
    def all_shared_elements
      MediaElement.where(:is_public => true).count
    end
    
    # Chart representing the distribution of subjects among lessons
    def subjects_chart
      tot = Lesson.count
      resp = []
      Subject.joins(:lessons).group('subjects.id').order('subjects.description ASC').count.each do |id, num|
        resp << percentage(num, tot)
      end
      resp
    end
    
    # Descriptions for Statistics#subjects_chart
    def subjects
      resp = []
      Subject.joins(:lessons).group('subjects.id').order('subjects.description ASC').each do |s|
        resp << s.description
      end
      resp
    end
    
    # Chart representing the size occupation of the folder 'public/media_elements'
    def hard_disk_chart
      resp = []
      max = Media::Uploader::MAXIMUM_MEDIA_ELEMENTS_FOLDER_SIZE
      resp << percentage(Media::Video::Uploader.folder_size, max)
      resp << percentage(Media::Audio::Uploader.folder_size, max)
      resp << percentage(ImageUploader.folder_size, max)
      resp << percentage(max - Media::Video::Uploader.folder_size - Media::Audio::Uploader.folder_size - ImageUploader.folder_size, max)
      resp
    end
    
    private
    
    # Submethod for chart percentages
    def percentage(val, tot)
      res = (val.to_f * 100) / tot.to_f
      res.round(2)
    end
    
  end
  
end
