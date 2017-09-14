require 'test_helper'

class AudioTest < ActiveSupport::TestCase
  
  def setup
    reset_parameters
  end
  
  def reset_parameters
    @parameters = {
      :initial_audio_id => 3,
      :components => [
        {
          :audio_id => 4,
          :from => 1,
          :to => 29
        },
        {
          :audio_id => 3,
          :from => 2,
          :to => 30
        },
        {
          :audio_id => 4,
          :from => 0,
          :to => 6
        }
      ]
    }
  end
  
  test 'convert_parameter_hash' do
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    assert_equal 62, Audio.total_prototype_time(@parameters)
    assert_nil Audio.convert_parameters('o', 2)
    assert_nil Audio.convert_parameters({}, 2)
    @parameters.delete :initial_audio_id
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:initial_audio_id] = nil
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:initial_audio_id] = @parameters[:initial_audio_id].to_s
    assert_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:initial_audio_id] = 6
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:initial_audio_id] = 99
    assert_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    MediaElement.where(:id => 3).update_all(:user_id => 1)
    assert_nil Audio.convert_parameters(@parameters, 2)
    MediaElement.where(:id => 3).update_all(:user_id => 2)
    MediaElement.where(:id => 3).update_all(:is_public => true)
    assert_nil Audio.convert_parameters(@parameters, 2)
    MediaElement.where(:id => 3).update_all(:is_public => false)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components] = '[]'
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components] = []
    assert_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0].delete(:audio_id)
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:audio_id] = '3'
    assert_nil Audio.convert_parameters(@parameters, 2)
    MediaElement.where(:id => 4).update_all(:is_public => false)
    @parameters[:components][0][:audio_id] = 4
    assert_nil Audio.convert_parameters(@parameters, 2)
    MediaElement.where(:id => 4).update_all(:is_public => true)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:from] = 't'
    assert_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:to] = '1'
    assert_nil Audio.convert_parameters(@parameters, 2)
    reset_parameters
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:to] = 1
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:from] = 2
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:to] = 195
    assert_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:to] = 194
    assert_not_nil Audio.convert_parameters(@parameters, 2)
    @parameters[:components][0][:from] = -1
    assert_nil Audio.convert_parameters(@parameters, 2)
  end
  
end
