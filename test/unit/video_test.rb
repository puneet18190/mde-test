require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  
  def setup
    reset_parameters
  end
  
  def reset_parameters
    @parameters = {
      :initial_video_id => 1,
      :audio_id => 4,
      :components => [
        {
          :type => 'video',
          :video_id => 2,
          :from => 12,
          :to => 20
        },
        {
          :type => 'text',
          :content => 'Titolo titolo titolo',
          :duration => 14,
          :background_color => 'red',
          :text_color => 'white'
        },
        {
          :type => 'image',
          :image_id => 6,
          :duration => 2
        }
      ]
    }
  end
  
  test 'convert_parameter_hash' do
    assert_not_nil Video.convert_parameters(@parameters, 1)
    assert_equal 26, Video.total_prototype_time(@parameters)
    assert_nil Video.convert_parameters('o', 1)
    assert_nil Video.convert_parameters({}, 1)
    @parameters.delete :initial_video_id
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:initial_video_id] = nil
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters.delete :audio_id
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:audio_id] = nil
    assert_not_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:initial_video_id] = @parameters[:initial_video_id].to_s
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:initial_video_id] = @parameters[:initial_video_id].to_i
    @parameters[:audio_id] = @parameters[:audio_id].to_s
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:initial_video_id] = 6
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:initial_video_id] = 99
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 1).update_all(:user_id => 2)
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 1).update_all(:user_id => 1)
    MediaElement.where(:id => 1).update_all(:is_public => true)
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 1).update_all(:is_public => false)
    @parameters[:audio_id] = 1
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:audio_id] = 99
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:audio_id] = 3
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components] = '[]'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components] = []
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:type] = 'viddeo'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:type] = 'video'
    @parameters[:components][0].delete(:video_id)
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:video_id] = '3'
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 2).update_all(:user_id => 2, :is_public => false)
    @parameters[:components][0][:video_id] = 2
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 2).update_all(:user_id => 1, :is_public => true)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:from] = 't'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:to] = '1'
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:to] = 12
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:to] = 11
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:to] = 22
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:to] = 21
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][0][:from] = -1
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:type] = 'sext'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:type] = 'text'
    @parameters[:components][1].delete(:content)
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:duration] = 't'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:duration] = 0
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:duration] = -3
    assert_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:text_color] = 'opoppp'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:text_color] = 'red'
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:background_color] = 'pink'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][1][:background_color] = 'light_blue'
    assert_not_nil Video.convert_parameters(@parameters, 1)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][2].delete(:image_id)
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 6).update_all(:is_public => false)
    @parameters[:components][2][:image_id] = 6
    assert_nil Video.convert_parameters(@parameters, 1)
    MediaElement.where(:id => 6).update_all(:is_public => true)
    reset_parameters
    assert_not_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][2][:duration] = 't'
    assert_nil Video.convert_parameters(@parameters, 1)
    @parameters[:components][2][:duration] = -6
    assert_nil Video.convert_parameters(@parameters, 1)
  end
  
end
