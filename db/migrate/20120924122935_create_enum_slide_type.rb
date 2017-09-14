class CreateEnumSlideType < ActiveRecord::Migration
  
  def up
    execute "CREATE TYPE slide_type AS ENUM ('cover', 'title', 'text', 'image1', 'image2', 'image3', 'image4', 'audio', 'video1', 'video2')"
  end
  
  def down
    execute "DROP TYPE slide_type"
  end
  
end
