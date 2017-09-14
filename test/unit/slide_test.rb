require 'test_helper'

class SlideTest < ActiveSupport::TestCase
  
  def setup
    @slide = Slide.new :position => 2, :title => 'Titolo', :text => 'Testo testo testo'
    @slide.lesson_id = 1
    @slide.kind = 'video1'
  end
  
  test 'empty_and_defaults' do
    @slide = Slide.new
    assert_error_size 6, @slide
  end
    
  test 'types' do
    assert_invalid @slide, :position, 'ret', 2, :not_a_number
    assert_invalid @slide, :position, -9, 2, :greater_than, {:count => 0}
    assert_invalid @slide, :lesson_id, 1.1, 1, :not_an_integer
    @slide.kind = 'audio3'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 3, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:kind].length
    assert @slide.errors.added? :kind, :inclusion
    @slide.kind = 'video1'
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    assert_invalid @slide, :title, long_string(256), long_string(255), :too_long, {:count => 255}
    @slide.title = nil
    assert_obj_saved @slide
  end
  
  test 'association_methods' do
    assert_nothing_raised {@slide.media_elements_slides}
    assert_nothing_raised {@slide.lesson}
    assert_nothing_raised {@slide.documents_slides}
  end
  
  test 'uniqueness' do
    @slide.lesson_id = 2
    assert_invalid @slide, :position, 2, 4, :taken
    # I rewrite manually assert_invalid
    @slide.kind = 'cover'
    old_text = @slide.text
    @slide.text = nil
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 2, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert @slide.errors.added? :kind, :taken
    @slide.kind = 'video1'
    @slide.text = old_text
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    # until here
    assert_obj_saved @slide
    assert_equal 2, Slide.where(:lesson_id => 2, :kind => 'video1').count
  end
  
  test 'associations' do
    assert_invalid @slide, :lesson_id, 1000, 1, :doesnt_exist
    assert_obj_saved @slide
  end
  
  test 'impossible_changes' do
    assert_obj_saved @slide
    # I rewrite manually assert_invalid
    @slide.position = 4
    @slide.lesson_id = 2
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 1, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert @slide.errors.added? :lesson_id, :cant_be_changed
    @slide.lesson_id = 1
    @slide.position = 2
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    # until here
    assert_invalid @slide, :kind, 'audio', 'video1', :cant_be_changed
    assert_obj_saved @slide
  end
  
  test 'cover' do
    assert_invalid @slide, :position, 1, 2, :if_not_cover_cant_be_first_slide
    assert_obj_saved @slide
    @slide = Slide.find 1
    assert_equal 'cover', @slide.kind
    assert_invalid @slide, :position, 3, 1, :cover_must_be_first_slide
    assert_obj_saved @slide
  end
  
  test 'destruction' do
    @slide = Slide.find 1
    @slide.destroy
    assert Slide.exists?(1)
    @lesson = Lesson.find 1
    @lesson.destroy
    assert !Lesson.exists?(1)
    assert !Slide.exists?(1)
  end
  
  test 'blank_text_and_title' do
    @slide.kind = 'video2'
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 2, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:title].length
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :title, :must_be_null_in_this_slide
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    @slide.title = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    @slide.kind = 'image2'
    @slide.title = 'beh'
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 2, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:title].length
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :title, :must_be_null_in_this_slide
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    @slide.title = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    @slide.kind = 'image3'
    @slide.title = 'beh'
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 2, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:title].length
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :title, :must_be_null_in_this_slide
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    @slide.title = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    @slide.kind = 'image4'
    @slide.title = 'beh'
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 2, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:title].length
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :title, :must_be_null_in_this_slide
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    @slide.title = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    @slide.kind = 'title'
    @slide.title = 'beh'
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 1, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    temmmporary_lesson = Lesson.first
    @slide = temmmporary_lesson.slides.first
    @slide.title = temmmporary_lesson.title
    @slide.text = 'ciao ciao ciao'
    assert !@slide.save, "Slide erroneously saved - #{@slide.inspect}"
    assert_equal 1, @slide.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{@slide.errors.inspect}"
    assert_equal 1, @slide.errors.messages[:text].length
    assert @slide.errors.added? :text, :must_be_null_in_this_slide
    @slide.text = nil
    assert @slide.valid?, "Slide not valid: #{@slide.errors.inspect}"
    assert_obj_saved @slide
  end
  
  test 'cover_title_different_by_lesson_title' do
    lesson = Lesson.find(1)
    cover = lesson.cover
    assert_equal cover.title, lesson.title
    assert_invalid cover, :title, 'tstrong', 'tstring', :in_cover_it_cant_be_different_by_lessons_title
    lesson.title = 'buahuahua'
    assert_obj_saved lesson
    cover = Slide.find cover.id
    assert_equal 'buahuahua', cover.title
  end
  
  test 'maximum_slides' do
    l = Lesson.find 1
    assert_equal 1, Slide.where(:lesson_id => l.id).count
    (2...100).to_a.each do |i|
      assert_not_nil l.add_slide('text', i)
    end
    s = Slide.new
    s.position = 100
    s.lesson_id = l.id
    s.kind = 'text'
    assert !s.save, "#Slide erroneously saved - #{s.inspect}"
    assert_equal 1, s.errors.messages.length, "A field which wasn't supposed to be affected returned error - #{s.errors.inspect}"
    assert_equal 1, s.errors.messages[:base].length
    assert s.errors.added? :base, :too_many_slides
    s2 = Slide.where(:position => 80).first
    assert s2.valid?
    s2.destroy
    assert_obj_saved s
  end
  
  test 'media_elements_at' do
    @lesson = Lesson.find(2)
    @cover = @lesson.cover
    @audio = Slide.where(:lesson_id => @lesson.id, :position => 2).first
    assert_equal 'audio', @audio.kind
    @image1 = @lesson.add_slide 'image1', 3
    assert_not_nil @image1
    @image2 = @lesson.add_slide 'image2', 4
    assert_not_nil @image2
    @image3 = @lesson.add_slide 'image3', 5
    assert_not_nil @image3
    @image4 = @lesson.add_slide 'image4', 6
    assert_not_nil @image4
    @video1 = Slide.where(:lesson_id => @lesson.id, :position => 7).first
    assert_equal 'video1', @video1.kind
    @video2 = @lesson.add_slide 'video2', 8
    assert_not_nil @video2
    @lesson = Lesson.find(@lesson.id)
    assert_equal 8, @lesson.slides.length
    # finished preliminar phase, I start testing the method now
    # 1 - cover
    assert MediaElementsSlide.where(:slide_id => @cover.id).empty?
    assert_nil @cover.media_elements_at
    @cover_1 = MediaElementsSlide.new
    @cover_1.slide_id = @cover.id
    @cover_1.position = 1
    @cover_1.alignment = 0
    @cover_1.media_element_id = 6
    assert_obj_saved @cover_1
    @cover = Slide.find(@cover.id)
    resp = @cover.media_elements_at
    assert_not_nil resp
    assert_equal MediaElementsSlide, resp.class
    assert_equal @cover_1.id, resp.id
    # 2 - image1
    assert MediaElementsSlide.where(:slide_id => @image1.id).empty?
    assert_nil @image1.media_elements_at
    @image1_1 = MediaElementsSlide.new
    @image1_1.slide_id = @image1.id
    @image1_1.position = 1
    @image1_1.alignment = 0
    @image1_1.media_element_id = 6
    assert_obj_saved @image1_1
    @image1 = Slide.find(@image1.id)
    resp = @image1.media_elements_at
    assert_not_nil resp
    assert_equal MediaElementsSlide, resp.class
    assert_equal @image1_1.id, resp.id
    # 3 - image2
    assert MediaElementsSlide.where(:slide_id => @image2.id).empty?
    resp1, resp2 = @image2.media_elements_at
    assert_nil resp1
    assert_nil resp2
    # position 2
    @image2_2 = MediaElementsSlide.new
    @image2_2.slide_id = @image2.id
    @image2_2.position = 2
    @image2_2.alignment = 0
    @image2_2.media_element_id = 6
    assert_obj_saved @image2_2
    @image2 = Slide.find(@image2.id)
    resp1, resp2 = @image2.media_elements_at
    assert_nil resp1
    assert_not_nil resp2
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image2_2.id, resp2.id
    # position 1
    @image2_1 = MediaElementsSlide.new
    @image2_1.slide_id = @image2.id
    @image2_1.position = 1
    @image2_1.alignment = 0
    @image2_1.media_element_id = 6
    assert_obj_saved @image2_1
    @image2 = Slide.find(@image2.id)
    resp1, resp2 = @image2.media_elements_at
    assert_not_nil resp1
    assert_not_nil resp2
    assert_equal MediaElementsSlide, resp1.class
    assert_equal @image2_1.id, resp1.id
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image2_2.id, resp2.id
    # 4 - image3
    assert MediaElementsSlide.where(:slide_id => @image3.id).empty?
    assert_nil @image3.media_elements_at
    @image3_1 = MediaElementsSlide.new
    @image3_1.slide_id = @image3.id
    @image3_1.position = 1
    @image3_1.alignment = 0
    @image3_1.media_element_id = 6
    assert_obj_saved @image3_1
    @image3 = Slide.find(@image3.id)
    resp = @image3.media_elements_at
    assert_not_nil resp
    assert_equal MediaElementsSlide, resp.class
    assert_equal @image3_1.id, resp.id
    # 5 - image4
    assert MediaElementsSlide.where(:slide_id => @image4.id).empty?
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_nil resp1
    assert_nil resp2
    assert_nil resp3
    assert_nil resp4
    # position 2
    @image4_2 = MediaElementsSlide.new
    @image4_2.slide_id = @image4.id
    @image4_2.position = 2
    @image4_2.alignment = 0
    @image4_2.media_element_id = 6
    assert_obj_saved @image4_2
    @image4 = Slide.find(@image4.id)
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_nil resp1
    assert_not_nil resp2
    assert_nil resp3
    assert_nil resp4
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image4_2.id, resp2.id
    # position 1
    @image4_1 = MediaElementsSlide.new
    @image4_1.slide_id = @image4.id
    @image4_1.position = 1
    @image4_1.alignment = 0
    @image4_1.media_element_id = 6
    assert_obj_saved @image4_1
    @image4 = Slide.find(@image4.id)
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_not_nil resp1
    assert_not_nil resp2
    assert_nil resp3
    assert_nil resp4
    assert_equal MediaElementsSlide, resp1.class
    assert_equal @image4_1.id, resp1.id
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image4_2.id, resp2.id
    # position 4
    @image4_4 = MediaElementsSlide.new
    @image4_4.slide_id = @image4.id
    @image4_4.position = 4
    @image4_4.alignment = 0
    @image4_4.media_element_id = 6
    assert_obj_saved @image4_4
    @image4 = Slide.find(@image4.id)
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_not_nil resp1
    assert_not_nil resp2
    assert_nil resp3
    assert_not_nil resp4
    assert_equal MediaElementsSlide, resp1.class
    assert_equal @image4_1.id, resp1.id
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image4_2.id, resp2.id
    assert_equal MediaElementsSlide, resp4.class
    assert_equal @image4_4.id, resp4.id
    # position 3
    @image4_3 = MediaElementsSlide.new
    @image4_3.slide_id = @image4.id
    @image4_3.position = 3
    @image4_3.alignment = 0
    @image4_3.media_element_id = 6
    assert_obj_saved @image4_3
    @image4 = Slide.find(@image4.id)
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_not_nil resp1
    assert_not_nil resp2
    assert_not_nil resp3
    assert_not_nil resp4
    assert_equal MediaElementsSlide, resp1.class
    assert_equal @image4_1.id, resp1.id
    assert_equal MediaElementsSlide, resp2.class
    assert_equal @image4_2.id, resp2.id
    assert_equal MediaElementsSlide, resp3.class
    assert_equal @image4_3.id, resp3.id
    assert_equal MediaElementsSlide, resp4.class
    assert_equal @image4_4.id, resp4.id
    # remove position 2
    @image4_2.destroy
    assert_nil MediaElementsSlide.find_by_id(@image4_2.id)
    @image4 = Slide.find(@image4.id)
    resp1, resp2, resp3, resp4 = @image4.media_elements_at
    assert_not_nil resp1
    assert_nil resp2
    assert_not_nil resp3
    assert_not_nil resp4
    assert_equal MediaElementsSlide, resp1.class
    assert_equal @image4_1.id, resp1.id
    assert_equal MediaElementsSlide, resp3.class
    assert_equal @image4_3.id, resp3.id
    assert_equal MediaElementsSlide, resp4.class
    assert_equal @image4_4.id, resp4.id
    # 6 - audio
    MediaElementsSlide.where(:slide_id => @audio.id).first.destroy
    assert MediaElementsSlide.where(:slide_id => @audio.id).empty?
    assert_nil @audio.media_elements_at
    @audio_1 = MediaElementsSlide.new
    @audio_1.slide_id = @audio.id
    @audio_1.position = 1
    @audio_1.media_element_id = 3
    assert_obj_saved @audio_1
    @audio = Slide.find(@audio.id)
    resp = @audio.media_elements_at
    assert_not_nil resp
    assert_equal Audio, resp.class
    assert_equal 3, resp.id
    # 7 - video1
    assert User.find(2).bookmark 'MediaElement', 2
    MediaElementsSlide.where(:slide_id => @video1.id).first.destroy
    assert MediaElementsSlide.where(:slide_id => @video1.id).empty?
    assert_nil @video1.media_elements_at
    @video1_1 = MediaElementsSlide.new
    @video1_1.slide_id = @video1.id
    @video1_1.position = 1
    @video1_1.media_element_id = 2
    assert_obj_saved @video1_1
    @video1 = Slide.find(@video1.id)
    resp = @video1.media_elements_at
    assert_not_nil resp
    assert_equal Video, resp.class
    assert_equal 2, resp.id
    # 8 - video2
    assert MediaElementsSlide.where(:slide_id => @video2.id).empty?
    assert_nil @video2.media_elements_at
    @video2_1 = MediaElementsSlide.new
    @video2_1.slide_id = @video2.id
    @video2_1.position = 1
    @video2_1.media_element_id = 2
    assert_obj_saved @video2_1
    @video2 = Slide.find(@video2.id)
    resp = @video2.media_elements_at
    assert_not_nil resp
    assert_equal Video, resp.class
    assert_equal 2, resp.id
  end
  
  test 'math_images' do
    begin
      assert_obj_saved @slide
      @slide.math_images.folder.mkpath
      wrong_img = Rails.root.join 'test/samples/one.jpg'
      right_img = Rails.root.join 'test/samples/valid math_image.png'
      # 1: the image is wrong (not png)
      FileUtils.cp wrong_img, @slide.math_images.folder
      @slide.math_images = [wrong_img]
      assert @slide.math_images.invalid?
      # 2: the image is not wrong, but it hasn't been copied in the required folder
      @slide.math_images = [right_img]
      assert @slide.math_images.invalid?
      # 3: finally, the image is right
      FileUtils.cp right_img, @slide.math_images.folder
      assert @slide.math_images.valid?
      # Now I start with the test of text
      assert_invalid @slide, :text, 'ciaoo <img class="Wirisformula" src="www.corrieredellosport.it"/>', 'ciaoo <img src="www.corrieredellosport.it"/>', :invalid_math_images_links
      assert_invalid @slide, :text, 'ciaoo <img class="Wirisformula" src="www.corrieredellosport.it?formula=bahh"/>', 'ciao', :invalid_math_images_links
      assert_invalid @slide, :text, 'ciaoo <img class="Wirisformula" src="www.corrieredellosport.it?formula=/ciao/pippo/pluto/valid%20math_image.png"/>', 'ciao', :invalid_math_images_links
      @slide.text = 'ciaoo <img class="Wirisformula" src="www.corrieredellosport.it?formula=valid%20math_image.png"/>'
      assert @slide.valid?
    ensure
      # Clean up of the folder in case of exception
      @slide.math_images.remove_folder
    end
  end
  
end
